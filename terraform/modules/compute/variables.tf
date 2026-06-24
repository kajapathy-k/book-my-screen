################################################################################
# COMPUTE MODULE VARIABLES
################################################################################

################################################################################
# VPC & NETWORKING (From Phase 1)
################################################################################

variable "vpc_id" {
  description = "VPC ID from Phase 1 networking module"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB placement"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "At least 2 public subnets required for ALB multi-AZ."
  }
}

variable "frontend_private_subnets" {
  description = "List of private app subnet IDs for Frontend EC2 placement"
  type        = list(string)

  validation {
    condition     = length(var.frontend_private_subnets) >= 1
    error_message = "At least 1 private app subnet required for Frontend EC2."
  }
}

variable "backend_private_subnets" {
  description = "List of private app subnet IDs for Backend EC2 placement"
  type        = list(string)

  validation {
    condition     = length(var.backend_private_subnets) >= 1
    error_message = "At least 1 private app subnet required for Backend EC2."
  }
}

################################################################################
# SECURITY GROUPS (From Phase 2)
################################################################################

variable "alb_sg_id" {
  description = "ALB Security Group ID from Phase 2 security module"
  type        = string

  validation {
    condition     = can(regex("^sg-", var.alb_sg_id))
    error_message = "Security Group ID must start with 'sg-'."
  }
}

variable "frontend_sg_id" {
  description = "Frontend Security Group ID from Phase 2 security module"
  type        = string

  validation {
    condition     = can(regex("^sg-", var.frontend_sg_id))
    error_message = "Security Group ID must start with 'sg-'."
  }
}

variable "backend_sg_id" {
  description = "Backend Security Group ID from Phase 2 security module"
  type        = string

  validation {
    condition     = can(regex("^sg-", var.backend_sg_id))
    error_message = "Security Group ID must start with 'sg-'."
  }
}

################################################################################
# EC2 CONFIGURATION
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
  description = "EC2 Instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must be t3.* for this phase."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

################################################################################
# PROJECT & ENVIRONMENT
################################################################################

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "bookmyscreen"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "documentdb_sg_id" {
  description = "Security group ID for DocumentDB"
  type        = string
}