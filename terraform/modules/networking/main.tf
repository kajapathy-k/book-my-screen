################################################################################
# AWS VPC - BookMyScreen Networking Foundation
################################################################################
# This module creates a production-grade, highly available, three-tier
# networking architecture supporting future deployment of ALB, EC2, DocumentDB,
# ElastiCache, S3, CloudFront, Route53, WAF, and other AWS services.

################################################################################
# DATA SOURCE: Availability Zones
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-vpc"
    }
  )
}

################################################################################
# INTERNET GATEWAY
################################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-igw"
    }
  )
}

################################################################################
# ELASTIC IP FOR NAT GATEWAY
################################################################################

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-eip-nat"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC
  depends_on = [aws_internet_gateway.main]
}

################################################################################
# NAT GATEWAY
################################################################################
# NAT Gateway is placed in Public Subnet A for outbound internet access
# from Private App Layer. Future Phase 1.5 will add redundant NAT Gateway
# in Public Subnet B for High Availability.

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-nat-gw"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

################################################################################
# PUBLIC SUBNETS (ALB Layer)
################################################################################

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-public-subnet-az-a"
      Type = "Public"
    }
  )
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-public-subnet-az-b"
      Type = "Public"
    }
  )
}

################################################################################
# PRIVATE APP SUBNETS (EC2 Instance Layer)
################################################################################

resource "aws_subnet" "private_app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-private-app-subnet-az-a"
      Type = "Private"
      Tier = "Application"
    }
  )
}

resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-private-app-subnet-az-b"
      Type = "Private"
      Tier = "Application"
    }
  )
}

################################################################################
# PRIVATE DATA SUBNETS (Database & Cache Layer)
################################################################################

resource "aws_subnet" "private_data_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-private-data-subnet-az-a"
      Type = "Private"
      Tier = "Data"
    }
  )
}

resource "aws_subnet" "private_data_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-private-data-subnet-az-b"
      Type = "Private"
      Tier = "Data"
    }
  )
}

################################################################################
# PUBLIC ROUTE TABLE
################################################################################
# Routes traffic destined for the internet (0.0.0.0/0) to the Internet Gateway

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-public-rt"
      Type = "Public"
    }
  )
}

################################################################################
# PUBLIC ROUTE TABLE ASSOCIATIONS
################################################################################

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

################################################################################
# PRIVATE APP ROUTE TABLE
################################################################################
# Routes traffic destined for the internet (0.0.0.0/0) to the NAT Gateway
# This allows EC2 instances to reach the internet without being directly
# exposed to inbound traffic

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-private-app-rt"
      Type = "Private"
      Tier = "Application"
    }
  )
}

################################################################################
# PRIVATE APP ROUTE TABLE ASSOCIATIONS
################################################################################

resource "aws_route_table_association" "private_app_a" {
  subnet_id      = aws_subnet.private_app_a.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "private_app_b" {
  subnet_id      = aws_subnet.private_app_b.id
  route_table_id = aws_route_table.private_app.id
}

################################################################################
# PRIVATE DATA ROUTE TABLE
################################################################################
# NO internet route. Database and cache layer must remain isolated from
# the internet. All communication is internal only via Security Groups.

resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-private-data-rt"
      Type = "Private"
      Tier = "Data"
    }
  )
}

################################################################################
# PRIVATE DATA ROUTE TABLE ASSOCIATIONS
################################################################################

resource "aws_route_table_association" "private_data_a" {
  subnet_id      = aws_subnet.private_data_a.id
  route_table_id = aws_route_table.private_data.id
}

resource "aws_route_table_association" "private_data_b" {
  subnet_id      = aws_subnet.private_data_b.id
  route_table_id = aws_route_table.private_data.id
}
