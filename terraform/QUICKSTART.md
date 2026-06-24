################################################################################
# QUICK START GUIDE
################################################################################
# Fast reference for deploying BookMyScreen Phase 1 Networking

## PREREQUISITES

1. Install Terraform >= 1.0
2. Install AWS CLI >= 2.0
3. Configure AWS credentials
4. Region: ap-south-1 (Mumbai)

## ONE-TIME SETUP

# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket bms-terraform-state-dev \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket bms-terraform-state-dev \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket bms-terraform-state-dev \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name bms-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

## DEPLOYMENT

# Navigate to dev environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Generate plan (review before applying)
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan

# View all outputs
terraform output

# Export outputs as JSON
terraform output -json > outputs.json

## VERIFICATION

# Check VPC
aws ec2 describe-vpcs --region ap-south-1 \
  --query 'Vpcs[?CidrBlock==`10.0.0.0/16`]'

# Check subnets
aws ec2 describe-subnets --region ap-south-1 \
  --filters "Name=cidr-block,Values=10.0.1.0/24,10.0.2.0/24,10.0.11.0/24,10.0.12.0/24,10.0.21.0/24,10.0.22.0/24"

# Check NAT Gateway
aws ec2 describe-nat-gateways --region ap-south-1

## CLEANUP

# Destroy all resources
cd terraform/environments/dev
terraform destroy

## OUTPUTS REFERENCE

VPC ID                   → terraform output vpc_id
Internet Gateway ID      → terraform output internet_gateway_id
NAT Gateway ID           → terraform output nat_gateway_id
NAT Gateway Public IP    → terraform output nat_gateway_public_ip
Elastic IP Allocation ID → terraform output elastic_ip_allocation_id

Public Subnets          → terraform output public_subnet_ids
Private App Subnets     → terraform output private_app_subnet_ids
Private Data Subnets    → terraform output private_data_subnet_ids

Route Tables            → terraform output public_route_table_id
                        → terraform output private_app_route_table_id
                        → terraform output private_data_route_table_id

Availability Zones      → terraform output availability_zones

Full Summary            → terraform output network_architecture_summary

## DIRECTORY STRUCTURE

terraform/
├── modules/
│   └── networking/           # Reusable module
│       ├── main.tf          # Resource definitions
│       ├── variables.tf      # Input variables
│       ├── outputs.tf        # Export values
│       └── locals.tf         # Local values & tagging
├── environments/
│   └── dev/                 # Development environment
│       ├── main.tf          # Module instantiation
│       ├── variables.tf      # Dev variables
│       ├── terraform.tfvars  # Dev values
│       └── outputs.tf        # Pass-through outputs
├── versions.tf              # Terraform versions
├── backend.tf               # State management guide
├── provider.tf              # Provider docs
├── QUICKSTART.md            # This file
└── README.md                # Full documentation

## ENVIRONMENT VARIABLES (OPTIONAL)

export AWS_REGION=ap-south-1
export AWS_PROFILE=default
export TF_VAR_project_name=bms
export TF_VAR_environment=dev

## TROUBLESHOOTING

# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Validate Terraform files
terraform validate

# Format Terraform files
terraform fmt -recursive

# Show current state
terraform state list
terraform state show 'module.networking.aws_vpc.main'

# Manually refresh state
terraform refresh

## NEXT STEPS (PHASE 2)

After Phase 1 networking is deployed:
1. Create Security Groups module
2. Create EC2 module with Launch Templates
3. Create Auto Scaling Groups
4. Deploy Application Load Balancer
5. Create RDS/DocumentDB module

## DOCUMENTATION

Full documentation:  README.md
Module details:      modules/networking/main.tf
Configuration docs:  environments/dev/

## SUPPORT

AWS Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest
Terraform Docs:    https://www.terraform.io/docs
AWS VPC Guide:      https://docs.aws.amazon.com/vpc/
