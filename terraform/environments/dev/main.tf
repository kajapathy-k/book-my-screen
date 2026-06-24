################################################################################
# DEV ENVIRONMENT - BOOKMYSCREEN INFRASTRUCTURE
################################################################################
# This Terraform configuration instantiates all modules for the development
# environment. It calls the networking and security modules and provides
# environment-specific variable values.
#
# Phases:
#   Phase 1: Networking (VPC, Subnets, Gateways, Routes)
#   Phase 2: Security (Security Groups)

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # PHASE 1: LOCAL STATE ONLY
  # Remote backend (S3 + DynamoDB) disabled for Phase 1
  # Will be enabled in Phase 2 for team collaboration
  # To use remote backend later, uncomment and configure:
  #
  # backend "s3" {
  #   bucket         = "bms-terraform-state-dev"
  #   key            = "networking/terraform.tfstate"
  #   region         = "ap-south-1"
  #   encrypt        = true
  #   use_lockfile   = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

################################################################################
# NETWORKING MODULE INSTANTIATION
################################################################################

module "networking" {
  source = "../../modules/networking"

  # VPC Configuration
  vpc_cidr = var.vpc_cidr

  # Public Subnet Configuration
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr

  # Private App Subnet Configuration
  private_app_subnet_a_cidr = var.private_app_subnet_a_cidr
  private_app_subnet_b_cidr = var.private_app_subnet_b_cidr

  # Private Data Subnet Configuration
  private_data_subnet_a_cidr = var.private_data_subnet_a_cidr
  private_data_subnet_b_cidr = var.private_data_subnet_b_cidr

  # Tagging
  project_name = var.project_name
  environment  = var.environment
  tags         = var.additional_tags
}

################################################################################
# PHASE 2: SECURITY MODULE INSTANTIATION
################################################################################

module "security" {
  source = "../../modules/security"

  # VPC ID from Phase 1 Networking
  vpc_id = module.networking.vpc_id

  # Tagging
  project_name = var.project_name
  environment  = var.environment
  tags         = var.additional_tags
}

################################################################################
# PHASE 3: COMPUTE MODULE INSTANTIATION
################################################################################

module "compute" {
  source = "../../modules/compute"

  # VPC & Networking (from Phase 1)
  vpc_id                     = module.networking.vpc_id
  public_subnets            = module.networking.public_subnet_ids
  frontend_private_subnets  = module.networking.private_app_subnet_ids
  backend_private_subnets   = module.networking.private_app_subnet_ids

  # Security Groups (from Phase 2)
  alb_sg_id       = module.security.alb_security_group_id
  frontend_sg_id  = module.security.frontend_security_group_id
  backend_sg_id   = module.security.backend_security_group_id
  documentdb_sg_id = module.security.documentdb_sg_id

  # EC2 Configuration
  ami        = var.ami
  instance_type = var.instance_type
  key_name   = var.key_name

  # Tagging
  project_name = var.project_name
  environment  = var.environment
  tags         = var.additional_tags

  depends_on = [module.security]
}



# module "kms" {
#   source = "../../modules/kms"
# }

# module "s3" {
#   source = "../../modules/s3"

#   bucket_name = "bms-movie-images-kajapathy"
#   kms_key_arn = module.kms.kms_key_arn
# }

# module "secrets_manager" {
#   source = "../../modules/secrets-manager"

#   mongo_connection_string = "mongodb://13.203.30.28:27017/bookmyscreen?replicaSet=rs0"
#   mongo_replica_string    = "mongodb://13.203.30.28:27017/bookmyscreen?replicaSet=rs0"

#   email_username = "kajapathy07@gmail.com"
#   email_password = "ulusaecbuxawvqkq"

#   hash_secret          = "kajapathy_hash_secret"
#   access_token_secret  = "kajapathy_access_token"
#   refresh_token_secret = "kajapathy_refresh_token"
# }

# ################################################################################
# # SNS Module
# ################################################################################

# module "sns" {
#   source = "../../modules/sns"

#   alert_email = "kajapathy07@gmail.com"
# }

# ################################################################################
# # CloudWatch Module
# ################################################################################

# module "cloudwatch" {
#   source = "../../modules/cloudwatch"

#   asg_name      = "bms-asg"
#   sns_topic_arn = module.sns.sns_topic_arn
# }

# module "cloudfront" {
#   source = "../../modules/cloudfront"
# }

# module "asg" {
#   source = "../../modules/asg"

#   ami_id             = "ami-07a00cf47dbbc844c"
#   key_pair_name      = "NewKey"

#   application_sg_id = module.compute.application_sg_id

#   private_subnet_ids = [
#     module.networking.private_app_subnet_az1_id,
#     module.networking.private_app_subnet_az2_id
#   ]

#   target_group_arn = module.compute.frontend_target_group_arn
# }