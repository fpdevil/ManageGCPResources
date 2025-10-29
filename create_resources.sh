#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Input the config file with key=value format"
    echo "usage: ./$0 <config.txt>"
    exit 1
fi

echo "$0 processing input from args $@"

# set variables from the input file
OLDIFS=$IFS
IFS="="
while read key value
do
    qvalue=$(eval echo $value)
    declare "${key}=$(echo $qvalue)"
done < $1
IFS=$OLDIFS

# Project ID
PROJECT_ID=$(gcloud config get-value project)

echo "${PROJECT_ID}: Project creation initiated..."

# Create a custom VPC
echo "Creating a custom VPC ${VPC_ID} in ${PROJECT_ID}..."
gcloud compute networks create ${VPC_ID} --project ${PROJECT_ID} --subnet-mode=custom

# Create a Subnet poc-vpc00-subnet01 in the custom mode of VPC
echo "Creating Subnet ${SUBNET01_ID} under ${VPC_ID} in ${PROJECT_ID}..."
gcloud compute networks subnets create ${SUBNET01_ID} \
    --network=${VPC_ID} \
    --range ${SUBNET01_CIDR} \
    --project ${PROJECT_ID} \
    --region ${REGION01}

# Create a Subnet poc-vpc00-subnet02 in the custom mode of VPC
echo "Creating Subnet ${SUBNET02_ID} under ${VPC_ID} in ${PROJECT_ID}..."
gcloud compute networks subnets create ${SUBNET02_ID} \
    --network=${VPC_ID} \
    --range ${SUBNET02_CIDR} \
    --project ${PROJECT_ID} \
    --region ${REGION02}

# Create VM for Terraform in the Specific VPC poc-vpc00 and Subnet poc-vpc00-subnet01
echo "Creating VM ${VM01} under VPC: ${VPC_ID} and SUBNET: ${SUBNET01_ID}"
gcloud compute instances create ${VM01} \
    --zone=${ZONE01} \
    --machine-type=${MACHINE_TYPE} \
    --subnet=${SUBNET01_ID} \
    --project ${PROJECT_ID} \
    --create-disk=auto-delete=yes,boot=yes,device-name=${VM01},image=${IMAGE_ID},mode=rw,size=10,type=pd-balanced \
    --tags=terraform,allow-ssh,allow-ping \
    --labels=environment=poc

# Create VM for Terraform in the Specific VPC poc-vpc00 and Subnet poc-vpc00-subnet02
echo "Creating VM ${VM02} under VPC: ${VPC_ID} and SUBNET: ${SUBNET02_ID}"
gcloud compute instances create ${VM02} \
    --zone=${ZONE02} \
    --machine-type=${MACHINE_TYPE} \
    --subnet=${SUBNET02_ID} \
    --project ${PROJECT_ID} \
    --create-disk=auto-delete=yes,boot=yes,device-name=${VM02},image=${IMAGE_ID},mode=rw,size=10,type=pd-balanced \
    --tags=docker,allow-ssh,allow-ping \
    --labels=environment=poc

# Open firewall(s) for poc-vpc00
echo "Creating a firewall rule allow-ssh-${VPC_ID} for SSH access in ${PROJECT_ID}"
gcloud compute firewall-rules create allow-ssh-${VPC_ID} \
    --direction=INGRESS \
    --priority=1000 \
    --network=${VPC_ID} \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=${SOURCE_CIDR} \
    --project=${PROJECT_ID}

echo "Creating a firewall rule allow-ping-${VPC_ID} for PING access in ${PROJECT_ID}"
gcloud compute firewall-rules create allow-ping-${VPC_ID} \
    --direction=INGRESS \
    --priority=1000 \
    --network=${VPC_ID} \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=${SOURCE_CIDR} \
    --project=${PROJECT_ID}

if [ $? -eq 0 ]
then
    date +"%d %h %Y script $0 executed successfully" >&2
else
    date +"%d %h %Y script $0 execution failed" >&2
fi
