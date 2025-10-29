# Create GCP resources

>[!NOTE] WIP
> This is still a WIP and new updates will be added
> The current scripts will run

Simple shell scripts to create and destroy resources on the `google cloud platform` for convenience.
In general, resources are maintained using `IaC` tools like `Terraform`, but these scripts will be handy while testing from local machines or in restricted environments where *3rd* party packages are not allowed to be installed.

## Scripts and Configurations
The scripts take input from the configuration file `config.txt` which can be adjusted as per the requirement.

+ `./create_resources.sh` :: For **Creating** the resources on `GCP`
+ `./delete_resources.sh` :: For **Destroying** the existing resources on GCP
+ `config.txt` :: Input data

### Usage
Here is how we can trigger the scripts:

```bash
# Create
./create_resources.sh config.txt

# Delete
./delete_resources.sh config.txt
```

The configuration file has below structure:
```sh
# Provide a meaningful name for ENV which will be prepended for all resources
ENV="poc"
VPC_ID="${ENV}-vpc00"
SUBNET01_ID="${VPC_ID}-subnet01"
SUBNET02_ID="${VPC_ID}-subnet02"

# Adjust the SUBNET values as needed
SUBNET01_CIDR="10.10.1.0/24"
SUBNET02_CIDR="10.10.2.0/24"

# Source is currently open which may be adjusted as needed
SOURCE_CIDR="0.0.0.0/0"

# Regions for resource creation
REGION01="us-east4"
REGION02="us-west4"
ZONE01="${REGION01}-c"
ZONE02="${REGION02}-c"
VM01="terraform-${ENV}"
VM02="docker-${ENV}"

# GCP VM Machine type
MACHINE_TYPE="e2-medium"

# GCP Linux Image name
IMAGE_ID="projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2504-plucky-amd64-v20250430"
```
