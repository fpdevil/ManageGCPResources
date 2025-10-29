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

echo "Project cleanup initiated..."

# Delete the Firewalls
echo "Deleting the Firewall allow-ssh-${VPC_ID} from ${PROJECT_ID}..."
gcloud compute firewall-rules delete allow-ssh-${VPC_ID} --project ${PROJECT_ID} --quiet

echo "Deleting the Firewall allow-ping-${VPC_ID} from ${PROJECT_ID}..."
gcloud compute firewall-rules delete allow-ping-${VPC_ID} --project ${PROJECT_ID} --quiet

# Delete the instances
echo "Deleting the instances ${VM01} in ${ZONE01} from ${PROJECT_ID}..."
gcloud compute instances delete ${VM01} --zone=${ZONE01} --project ${PROJECT_ID} --quiet

echo "Deleting the instances ${VM02} in ${ZONE02} from ${PROJECT_ID}..."
gcloud compute instances delete ${VM02} --zone=${ZONE02} --project ${PROJECT_ID} --quiet

# Delete the Subnets
echo "Deleting Subnet ${SUBNET01_ID} under ${VPC_ID}..."
gcloud compute networks subnets delete ${SUBNET01_ID} --region=${REGION01} --project ${PROJECT_ID} --quiet

echo "Deleting Subnet ${SUBNET02_ID} under ${VPC_ID}..."
gcloud compute networks subnets delete ${SUBNET02_ID} --region=${REGION02} --project ${PROJECT_ID} --quiet

# Finally, Delete the Custom VPC
echo "Finally, deleting the custom VPC ${VPC_ID}..."
gcloud compute networks delete ${VPC_ID} --project ${PROJECT_ID} --quiet

if [ $? -eq 0 ]
then
    date +"%d %h %Y script $0 executed successfully" >&2
else
    date +"%d %h %Y script $0 execution failed" >&2
fi
