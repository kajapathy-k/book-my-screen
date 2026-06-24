################################################################################
# NETWORKING MODULE OUTPUTS
################################################################################
# These outputs expose critical networking resource identifiers for consumption
# by other modules in Phase 2+ (EC2, DocumentDB, ElastiCache, ALB, etc.)

################################################################################
# VPC OUTPUTS
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

################################################################################
# INTERNET GATEWAY OUTPUTS
################################################################################

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

################################################################################
# NAT GATEWAY OUTPUTS
################################################################################

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

################################################################################
# ELASTIC IP OUTPUTS
################################################################################

output "elastic_ip_allocation_id" {
  description = "The allocation ID of the Elastic IP for NAT Gateway"
  value       = aws_eip.nat.id
}

output "elastic_ip_public_ip" {
  description = "The public IP address of the Elastic IP"
  value       = aws_eip.nat.public_ip
}

################################################################################
# PUBLIC SUBNET OUTPUTS
################################################################################

output "public_subnet_a_id" {
  description = "The ID of Public Subnet A (AZ-A)"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "The ID of Public Subnet B (AZ-B)"
  value       = aws_subnet.public_b.id
}

output "public_subnet_ids" {
  description = "List of all public subnet IDs"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "public_subnet_a_cidr" {
  description = "CIDR block of Public Subnet A"
  value       = aws_subnet.public_a.cidr_block
}

output "public_subnet_b_cidr" {
  description = "CIDR block of Public Subnet B"
  value       = aws_subnet.public_b.cidr_block
}

################################################################################
# PRIVATE APPLICATION SUBNET OUTPUTS
################################################################################

output "private_app_subnet_a_id" {
  description = "The ID of Private App Subnet A (AZ-A)"
  value       = aws_subnet.private_app_a.id
}

output "private_app_subnet_b_id" {
  description = "The ID of Private App Subnet B (AZ-B)"
  value       = aws_subnet.private_app_b.id
}

output "private_app_subnet_ids" {
  description = "List of all private app subnet IDs"
  value       = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
}

output "private_app_subnet_a_cidr" {
  description = "CIDR block of Private App Subnet A"
  value       = aws_subnet.private_app_a.cidr_block
}

output "private_app_subnet_b_cidr" {
  description = "CIDR block of Private App Subnet B"
  value       = aws_subnet.private_app_b.cidr_block
}

################################################################################
# PRIVATE DATA SUBNET OUTPUTS
################################################################################

output "private_data_subnet_a_id" {
  description = "The ID of Private Data Subnet A (AZ-A)"
  value       = aws_subnet.private_data_a.id
}

output "private_data_subnet_b_id" {
  description = "The ID of Private Data Subnet B (AZ-B)"
  value       = aws_subnet.private_data_b.id
}

output "private_data_subnet_ids" {
  description = "List of all private data subnet IDs"
  value       = [aws_subnet.private_data_a.id, aws_subnet.private_data_b.id]
}

output "private_data_subnet_a_cidr" {
  description = "CIDR block of Private Data Subnet A"
  value       = aws_subnet.private_data_a.cidr_block
}

output "private_data_subnet_b_cidr" {
  description = "CIDR block of Private Data Subnet B"
  value       = aws_subnet.private_data_b.cidr_block
}

################################################################################
# ROUTE TABLE OUTPUTS
################################################################################

output "public_route_table_id" {
  description = "The ID of the Public Route Table"
  value       = aws_route_table.public.id
}

output "private_app_route_table_id" {
  description = "The ID of the Private App Route Table"
  value       = aws_route_table.private_app.id
}

output "private_data_route_table_id" {
  description = "The ID of the Private Data Route Table"
  value       = aws_route_table.private_data.id
}

################################################################################
# AVAILABILITY ZONES OUTPUTS
################################################################################

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}

output "primary_availability_zone" {
  description = "Primary availability zone (AZ-A)"
  value       = data.aws_availability_zones.available.names[0]
}

output "secondary_availability_zone" {
  description = "Secondary availability zone (AZ-B)"
  value       = data.aws_availability_zones.available.names[1]
}

################################################################################
# NETWORK SUMMARY OUTPUTS
################################################################################

output "network_architecture_summary" {
  description = "Summary of the network architecture created"
  value = {
    vpc = {
      id   = aws_vpc.main.id
      cidr = aws_vpc.main.cidr_block
    }
    public_tier = {
      subnets = [
        {
          id   = aws_subnet.public_a.id
          cidr = aws_subnet.public_a.cidr_block
          az   = aws_subnet.public_a.availability_zone
        },
        {
          id   = aws_subnet.public_b.id
          cidr = aws_subnet.public_b.cidr_block
          az   = aws_subnet.public_b.availability_zone
        }
      ]
    }
    private_app_tier = {
      subnets = [
        {
          id   = aws_subnet.private_app_a.id
          cidr = aws_subnet.private_app_a.cidr_block
          az   = aws_subnet.private_app_a.availability_zone
        },
        {
          id   = aws_subnet.private_app_b.id
          cidr = aws_subnet.private_app_b.cidr_block
          az   = aws_subnet.private_app_b.availability_zone
        }
      ]
    }
    private_data_tier = {
      subnets = [
        {
          id   = aws_subnet.private_data_a.id
          cidr = aws_subnet.private_data_a.cidr_block
          az   = aws_subnet.private_data_a.availability_zone
        },
        {
          id   = aws_subnet.private_data_b.id
          cidr = aws_subnet.private_data_b.cidr_block
          az   = aws_subnet.private_data_b.availability_zone
        }
      ]
    }
    gateways = {
      internet_gateway_id = aws_internet_gateway.main.id
      nat_gateway_id      = aws_nat_gateway.main.id
      nat_gateway_eip     = aws_eip.nat.public_ip
    }
    route_tables = {
      public_rt       = aws_route_table.public.id
      private_app_rt  = aws_route_table.private_app.id
      private_data_rt = aws_route_table.private_data.id
    }
  }
}
