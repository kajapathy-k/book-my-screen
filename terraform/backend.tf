################################################################################
# TERRAFORM BACKEND CONFIGURATION
################################################################################
# PHASE 1: LOCAL STATE ONLY
#
# For Phase 1 networking deployment, Terraform uses local state files.
# Remote backend is disabled to simplify initial deployment.
#
# Local State Files:
#   - Location: .terraform/terraform.tfstate (in environments/dev)
#   - Backup: .terraform/terraform.tfstate.backup
#   - Lock File: .terraform.lock.hcl
#
# State File Management:
#   - Keep these files in the working directory
#   - Do NOT commit to version control
#   - Backup before running terraform destroy
#
# FUTURE: PHASE 2 REMOTE BACKEND
# ===============================
# When multiple team members need to collaborate, enable S3 backend:
#
# 1. Create S3 bucket:
#    aws s3api create-bucket \
#      --bucket bms-terraform-state-dev \
#      --region ap-south-1 \
#      --create-bucket-configuration LocationConstraint=ap-south-1
#
# 2. Enable versioning:
#    aws s3api put-bucket-versioning \
#      --bucket bms-terraform-state-dev \
#      --versioning-configuration Status=Enabled
#
# 3. Block public access:
#    aws s3api put-public-access-block \
#      --bucket bms-terraform-state-dev \
#      --public-access-block-configuration \
#      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
#
# 4. Uncomment backend block in environments/dev/main.tf:
#    terraform {
#      backend "s3" {
#        bucket       = "bms-terraform-state-dev"
#        key          = "networking/terraform.tfstate"
#        region       = "ap-south-1"
#        encrypt      = true
#        use_lockfile = true
#      }
#    }
#
# 5. Run terraform init to migrate state:
#    cd environments/dev
#    terraform init
