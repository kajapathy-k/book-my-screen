################################################################################
# DEV ENVIRONMENT - OUTPUTS
################################################################################
# These outputs expose the networking infrastructure details from the
# networking module for reference and for consumption by other modules
# in Phase 2+ deployments.

################################################################################
# VPC OUTPUTS
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

################################################################################
# INTERNET GATEWAY OUTPUTS
################################################################################

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.networking.internet_gateway_id
}

################################################################################
# NAT GATEWAY OUTPUTS
################################################################################

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = module.networking.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = module.networking.nat_gateway_public_ip
}

################################################################################
# ELASTIC IP OUTPUTS
################################################################################

output "elastic_ip_allocation_id" {
  description = "The allocation ID of the Elastic IP for NAT Gateway"
  value       = module.networking.elastic_ip_allocation_id
}

output "elastic_ip_public_ip" {
  description = "The public IP address of the Elastic IP"
  value       = module.networking.elastic_ip_public_ip
}

################################################################################
# PUBLIC SUBNET OUTPUTS
################################################################################

output "public_subnet_a_id" {
  description = "The ID of Public Subnet A (AZ-A)"
  value       = module.networking.public_subnet_a_id
}

output "public_subnet_b_id" {
  description = "The ID of Public Subnet B (AZ-B)"
  value       = module.networking.public_subnet_b_id
}

output "public_subnet_ids" {
  description = "List of all public subnet IDs"
  value       = module.networking.public_subnet_ids
}

################################################################################
# PRIVATE APPLICATION SUBNET OUTPUTS
################################################################################

output "private_app_subnet_a_id" {
  description = "The ID of Private App Subnet A (AZ-A)"
  value       = module.networking.private_app_subnet_a_id
}

output "private_app_subnet_b_id" {
  description = "The ID of Private App Subnet B (AZ-B)"
  value       = module.networking.private_app_subnet_b_id
}

output "private_app_subnet_ids" {
  description = "List of all private app subnet IDs"
  value       = module.networking.private_app_subnet_ids
}

################################################################################
# PRIVATE DATA SUBNET OUTPUTS
################################################################################

output "private_data_subnet_a_id" {
  description = "The ID of Private Data Subnet A (AZ-A)"
  value       = module.networking.private_data_subnet_a_id
}

output "private_data_subnet_b_id" {
  description = "The ID of Private Data Subnet B (AZ-B)"
  value       = module.networking.private_data_subnet_b_id
}

output "private_data_subnet_ids" {
  description = "List of all private data subnet IDs"
  value       = module.networking.private_data_subnet_ids
}

################################################################################
# ROUTE TABLE OUTPUTS
################################################################################

output "public_route_table_id" {
  description = "The ID of the Public Route Table"
  value       = module.networking.public_route_table_id
}

output "private_app_route_table_id" {
  description = "The ID of the Private App Route Table"
  value       = module.networking.private_app_route_table_id
}

output "private_data_route_table_id" {
  description = "The ID of the Private Data Route Table"
  value       = module.networking.private_data_route_table_id
}

################################################################################
# AVAILABILITY ZONES OUTPUTS
################################################################################

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.networking.availability_zones
}

output "primary_availability_zone" {
  description = "Primary availability zone (AZ-A)"
  value       = module.networking.primary_availability_zone
}

output "secondary_availability_zone" {
  description = "Secondary availability zone (AZ-B)"
  value       = module.networking.secondary_availability_zone
}

################################################################################
# NETWORK SUMMARY OUTPUT
################################################################################

output "network_architecture_summary" {
  description = "Complete summary of the deployed network architecture"
  value       = module.networking.network_architecture_summary
}

################################################################################
# TERRAFORM STATE REFERENCE
################################################################################

output "deployment_info" {
  description = "Deployment information for reference"
  value = {
    environment = var.environment
    region      = var.aws_region
    project     = var.project_name
    timestamp   = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  }
}

################################################################################
# PHASE 2: SECURITY GROUP OUTPUTS
################################################################################

output "alb_security_group_id" {
  description = "The ID of the ALB Security Group"
  value       = module.security.alb_security_group_id
}

output "frontend_security_group_id" {
  description = "The ID of the Frontend Security Group"
  value       = module.security.frontend_security_group_id
}

output "backend_security_group_id" {
  description = "The ID of the Backend Security Group"
  value       = module.security.backend_security_group_id
}

output "documentdb_security_group_id" {
  description = "The ID of the DocumentDB Security Group"
  value       = module.security.documentdb_security_group_id
}

output "redis_security_group_id" {
  description = "The ID of the Redis Security Group"
  value       = module.security.redis_security_group_id
}

################################################################################
# SECURITY GROUPS SUMMARY
################################################################################

output "security_groups_summary" {
  description = "Summary of all security groups created in Phase 2"
  value       = module.security.security_groups_summary
}

output "security_architecture_diagram" {
  description = "Security architecture traffic flow"
  value       = module.security.security_architecture_diagram
}

################################################################################
# PHASE 3: COMPUTE OUTPUTS
################################################################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer for accessing the application"
  value       = module.compute.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.compute.alb_arn
}

output "frontend_target_group_arn" {
  description = "ARN of the Frontend Target Group"
  value       = module.compute.frontend_target_group_arn
}

output "backend_target_group_arn" {
  description = "ARN of the Backend Target Group"
  value       = module.compute.backend_target_group_arn
}

output "frontend_instance_id" {
  description = "The ID of the Frontend EC2 instance"
  value       = module.compute.frontend_instance_id
}

output "frontend_private_ip" {
  description = "The private IP address of the Frontend EC2 instance"
  value       = module.compute.frontend_private_ip
}

output "backend_instance_id" {
  description = "The ID of the Backend EC2 instance"
  value       = module.compute.backend_instance_id
}

output "backend_private_ip" {
  description = "The private IP address of the Backend EC2 instance"
  value       = module.compute.backend_private_ip
}

################################################################################
# APPLICATION ACCESS INFORMATION
################################################################################

output "application_access_url" {
  description = "URL to access the BookMyScreen application"
  value       = module.compute.application_access_url
}

output "testing_information" {
  description = "Detailed testing information for the application"
  value       = module.compute.testing_information
}

################################################################################
# COMPUTE ARCHITECTURE SUMMARY
################################################################################

output "compute_architecture_summary" {
  description = "Summary of the compute architecture deployed in Phase 3"
  value       = module.compute.compute_architecture_summary
}
