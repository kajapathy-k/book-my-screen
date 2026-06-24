# ###############################################################################
# TERRAFORM PROVIDER CONFIGURATION
# ###############################################################################
# This file documents the provider configuration pattern.
# Actual provider configuration is done in each environment's main.tf

# NOTE: Provider configuration is NOT duplicated here. Each environment
# (dev, staging, production) has its own main.tf that configures the
# AWS provider with region-specific settings and default tags.

# This approach allows:
# 1. Different regions per environment (if needed)
# 2. Different AWS accounts per environment (if needed)
# 3. Environment-specific default tags
# 4. Isolated state files per environment

# PROVIDER CONFIGURATION EXAMPLE
# ==============================

# The following is an example of how the AWS provider is configured
# in each environment's main.tf file:

# terraform {
#   required_version = ">= 1.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.aws_region

#   default_tags {
#     tags = {
#       Project     = var.project_name
#       Environment = var.environment
#       ManagedBy   = "Terraform"
#     }
#   }
# }

# SUPPORTED REGIONS FOR PHASE 1 NETWORKING
# =========================================

# Current: ap-south-1 (Mumbai)

# Future expansion to other regions:
# - us-east-1 (N. Virginia)
# - eu-west-1 (Ireland)
# - ap-northeast-1 (Tokyo)
