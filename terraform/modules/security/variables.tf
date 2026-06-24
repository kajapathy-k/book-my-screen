################################################################################
# SECURITY MODULE VARIABLES
################################################################################

################################################################################
# VPC CONFIGURATION (Required from Phase 1 Networking)
################################################################################

variable "vpc_id" {
  description = "VPC ID from Phase 1 networking module"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

################################################################################
# TAGGING VARIABLES
################################################################################

variable "project_name" {
  description = "Project name to be used as prefix for all resources"
  type        = string
  default     = "bms"
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

################################################################################
# SECURITY GROUP NAMING CONFIGURATION
################################################################################

variable "alb_sg_name" {
  description = "Name for ALB security group"
  type        = string
  default     = null

  validation {
    condition     = var.alb_sg_name == null || can(regex("^[a-zA-Z0-9_-]*$", var.alb_sg_name))
    error_message = "Security group name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "frontend_sg_name" {
  description = "Name for Frontend security group"
  type        = string
  default     = null

  validation {
    condition     = var.frontend_sg_name == null || can(regex("^[a-zA-Z0-9_-]*$", var.frontend_sg_name))
    error_message = "Security group name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "backend_sg_name" {
  description = "Name for Backend security group"
  type        = string
  default     = null

  validation {
    condition     = var.backend_sg_name == null || can(regex("^[a-zA-Z0-9_-]*$", var.backend_sg_name))
    error_message = "Security group name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "documentdb_sg_name" {
  description = "Name for DocumentDB security group"
  type        = string
  default     = null

  validation {
    condition     = var.documentdb_sg_name == null || can(regex("^[a-zA-Z0-9_-]*$", var.documentdb_sg_name))
    error_message = "Security group name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "redis_sg_name" {
  description = "Name for Redis security group"
  type        = string
  default     = null

  validation {
    condition     = var.redis_sg_name == null || can(regex("^[a-zA-Z0-9_-]*$", var.redis_sg_name))
    error_message = "Security group name must contain only alphanumeric characters, underscores, and hyphens."
  }
}
