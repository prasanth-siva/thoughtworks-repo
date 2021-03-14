Terraform is responsible for provisioning infrastructure on AWS while Ansible helps delpoy Mediawiki.

# How to Execute Terrform Scripts

# Preparing Master Machine
Spinup a Master Machine and follow the below steps to install the necessary packages

# Install Terraform
wget https://releases.hashicorp.com/terraform/0.12.17/terraform_0.12.17_linux_amd64.zip

sudo mkdir /bin/terraform

sudo unzip terraform_0.12.17_linux_amd64.zip -d /usr/local/bin/terraform

export PATH=$PATH:/usr/local/bin/terraform

# Install Ansible
sudo apt-add-repository -y ppa:ansible/ansible

sudo apt-get update

sudo apt-get -y install ansible

**Create an S3 bucket as mentioned as the backend in the code to store the tf state files**

_export the AWS SECRET KEY & ACCESS KEY & REGION_

# Initialize 
> terraform init

# Plan
> terraform plan -var="instance_type=prod_setup" -var-file=prod.tfvars -input=false

# Apply
> terraform apply -var="instance_type=prod_setup" -var-file=prod.tfvars -input=false -auto-approve

# Destroy
> terraform destroy -var="instance_type=prod_setup" -var-file=prod.tfvars -input=false -auto-approve
