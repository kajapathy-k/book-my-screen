################################################################################
# DEV ENVIRONMENT - VARIABLES
################################################################################

################################################################################
# AWS REGION CONFIGURATION
################################################################################

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

################################################################################
# PROJECT CONFIGURATION
################################################################################

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "bms"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

################################################################################
# VPC CONFIGURATION
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

################################################################################
# PUBLIC SUBNET CONFIGURATION
################################################################################

variable "public_subnet_a_cidr" {
  description = "CIDR block for Public Subnet A"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_a_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for Public Subnet B"
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_b_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

################################################################################
# PRIVATE APPLICATION SUBNET CONFIGURATION
################################################################################

variable "private_app_subnet_a_cidr" {
  description = "CIDR block for Private App Subnet A"
  type        = string
  default     = "10.0.11.0/24"

  validation {
    condition     = can(cidrhost(var.private_app_subnet_a_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "private_app_subnet_b_cidr" {
  description = "CIDR block for Private App Subnet B"
  type        = string
  default     = "10.0.12.0/24"

  validation {
    condition     = can(cidrhost(var.private_app_subnet_b_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

################################################################################
# PRIVATE DATA SUBNET CONFIGURATION
################################################################################

variable "private_data_subnet_a_cidr" {
  description = "CIDR block for Private Data Subnet A"
  type        = string
  default     = "10.0.21.0/24"

  validation {
    condition     = can(cidrhost(var.private_data_subnet_a_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "private_data_subnet_b_cidr" {
  description = "CIDR block for Private Data Subnet B"
  type        = string
  default     = "10.0.22.0/24"

  validation {
    condition     = can(cidrhost(var.private_data_subnet_b_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

################################################################################
# ADDITIONAL TAGS
################################################################################

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Team      = "CloudInfrastructure"
    CostCode  = "BMS-CLOUD"
  }
}

################################################################################
# PHASE 3: COMPUTE CONFIGURATION
################################################################################

variable "ami" {
  description = "Ubuntu Server AMI ID for EC2 instances (ap-south-1)"
  type        = string
  default     = "ami-07a00cf47dbbc844c"

  validation {
    condition     = can(regex("^ami-", var.ami))
    error_message = "AMI ID must start with 'ami-'."
  }
}

variable "instance_type" {
  description = "EC2 Instance type for Frontend and Backend"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must be t3.* for this phase."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access to instances"
  type        = string
}
