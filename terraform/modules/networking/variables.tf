################################################################################
# NETWORKING MODULE VARIABLES
################################################################################

################################################################################
# VPC Configuration
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

################################################################################
# PUBLIC SUBNET CONFIGURATION
################################################################################

variable "public_subnet_a_cidr" {
  description = "CIDR block for Public Subnet A (AZ-A). Used for ALB and NAT Gateway."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for Public Subnet B (AZ-B). Used for ALB and future redundancy."
  type        = string
  default     = "10.0.2.0/24"
}

################################################################################
# PRIVATE APPLICATION SUBNET CONFIGURATION
################################################################################

variable "private_app_subnet_a_cidr" {
  description = "CIDR block for Private App Subnet A (AZ-A). Used for EC2 Frontend and Backend."
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_app_subnet_b_cidr" {
  description = "CIDR block for Private App Subnet B (AZ-B). Used for EC2 Frontend and Backend."
  type        = string
  default     = "10.0.12.0/24"
}

################################################################################
# PRIVATE DATA SUBNET CONFIGURATION
################################################################################

variable "private_data_subnet_a_cidr" {
  description = "CIDR block for Private Data Subnet A (AZ-A). Used for DocumentDB and ElastiCache."
  type        = string
  default     = "10.0.21.0/24"
}

variable "private_data_subnet_b_cidr" {
  description = "CIDR block for Private Data Subnet B (AZ-B). Used for DocumentDB and ElastiCache."
  type        = string
  default     = "10.0.22.0/24"
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
