################################################################################
# AWS Security Groups - BookMyScreen Phase 2 Security Architecture
################################################################################
# This module creates a production-grade, zero-trust security group architecture
# enforcing least privilege access across application tiers.
#
# Traffic Flow:
#   Internet → ALB → Frontend → Backend → DocumentDB/Redis
#
# Key Principle: Each tier only accepts traffic from the tier above it

################################################################################
# 1. ALB SECURITY GROUP
################################################################################
# Public-facing security group for Application Load Balancer
# Accepts HTTP and HTTPS from anywhere (intended for public web service)
# Acts as the entry point to the application

resource "aws_security_group" "alb" {
  name        = "${local.project_name}-alb-sg"
  description = "Security group for Application Load Balancer - BookMyScreen Phase 2"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-alb-sg"
      Role = "LoadBalancer"
    }
  )
}

# ALB Inbound: HTTP from Internet
resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from internet for ALB"
}

# ALB Inbound: HTTPS from Internet
resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from internet for ALB"
}

# ALB Outbound: All Traffic (to reach all backend services)
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic from ALB"
}

################################################################################
# 2. FRONTEND SECURITY GROUP
################################################################################
# Security group for Frontend (React/Vite) EC2 instances
# Only accepts HTTP/HTTPS from ALB
# Completely hidden from internet (not in public subnets, no direct internet route)

resource "aws_security_group" "frontend" {
  name        = "${local.project_name}-frontend-sg"
  description = "Security group for Frontend EC2 instances - BookMyScreen Phase 2"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-frontend-sg"
      Role = "Frontend"
    }
  )
}

# Frontend Inbound: HTTP from ALB only
resource "aws_security_group_rule" "frontend_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.frontend.id
  description              = "Allow HTTP from ALB to frontend"
}

# Frontend Inbound: HTTPS from ALB only
resource "aws_security_group_rule" "frontend_https_from_alb" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.frontend.id
  description              = "Allow HTTPS from ALB to frontend"
}

# resource "aws_vpc_security_group_ingress_rule" "frontend_from_alb_5173" {
#   security_group_id            = aws_security_group.frontend.id
#   referenced_security_group_id = aws_security_group.alb.id

#   from_port   = 5173
#   to_port     = 5173
#   ip_protocol = "tcp"
# }

# Frontend Outbound: All Traffic (for updates, logging, backend calls)
resource "aws_security_group_rule" "frontend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend.id
  description       = "Allow all outbound traffic from frontend"
}

################################################################################
# 3. BACKEND SECURITY GROUP
################################################################################
# Security group for Backend (Node.js/Express) EC2 instances
# Only accepts traffic on port 9000 from Frontend
# Connects to DocumentDB and Redis in data layer

resource "aws_security_group" "backend" {
  name        = "${local.project_name}-backend-sg"
  description = "Security group for Backend EC2 instances - BookMyScreen Phase 2"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-backend-sg"
      Role = "Backend"
    }
  )
}

# Backend Inbound: Port 9000 from Frontend only
resource "aws_security_group_rule" "backend_from_frontend" {
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend.id
  security_group_id        = aws_security_group.backend.id
  description              = "Allow port 9000 from frontend (Node.js/Socket.IO)"
}

# resource "aws_security_group_rule" "backend_from_alb" {
#   type                     = "ingress"
#   from_port                = 9000
#   to_port                  = 9000
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.alb.id
#   security_group_id        = aws_security_group.backend.id
#   description              = "Allow port 9000 from ALB"
# }

# Backend Outbound: All Traffic (to reach DocumentDB, Redis, external APIs)
resource "aws_security_group_rule" "backend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
  description       = "Allow all outbound traffic from backend"
}

################################################################################
# 4. DOCUMENTDB SECURITY GROUP
################################################################################
# Security group for Amazon DocumentDB cluster (MongoDB-compatible)
# Only accepts MongoDB wire protocol (port 27017) from Backend
# Completely isolated from public access

resource "aws_security_group" "documentdb" {
  name        = "${local.project_name}-documentdb-sg"
  description = "Security group for Amazon DocumentDB - BookMyScreen Phase 2"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-documentdb-sg"
      Role = "Database"
    }
  )
}

# DocumentDB Inbound: MongoDB port 27017 from Backend only
resource "aws_security_group_rule" "documentdb_from_backend" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend.id
  security_group_id        = aws_security_group.documentdb.id
  description              = "Allow MongoDB wire protocol from backend"
}

# DocumentDB Outbound: All Traffic (return traffic to backend)
resource "aws_security_group_rule" "documentdb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.documentdb.id
  description       = "Allow all outbound traffic from DocumentDB"
}

################################################################################
# 5. REDIS SECURITY GROUP
################################################################################
# Security group for Amazon ElastiCache Redis cluster
# Only accepts Redis protocol (port 6379) from Backend
# Completely isolated from public access

resource "aws_security_group" "redis" {
  name        = "${local.project_name}-redis-sg"
  description = "Security group for Amazon ElastiCache Redis - BookMyScreen Phase 2"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-redis-sg"
      Role = "Cache"
    }
  )
}

# Redis Inbound: Port 6379 from Backend only
resource "aws_security_group_rule" "redis_from_backend" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend.id
  security_group_id        = aws_security_group.redis.id
  description              = "Allow Redis protocol from backend"
}

# Redis Outbound: All Traffic (return traffic to backend)
resource "aws_security_group_rule" "redis_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis.id
  description       = "Allow all outbound traffic from Redis"
}

################################################################################
# SECURITY ARCHITECTURE SUMMARY
################################################################################
#
# Tier Hierarchy:
# 1. ALB (Public internet-facing)
#    ↓ Forwards to port 80/443
# 2. Frontend (Private app subnet)
#    ↓ Calls port 9000
# 3. Backend (Private app subnet)
#    ↓ Connects to ports 27017 (DocumentDB) and 6379 (Redis)
# 4. Data Services (Private data subnet)
#    - DocumentDB on port 27017
#    - Redis on port 6379
#
# Security Properties:
# ✓ No direct internet to backend
# ✓ No direct internet to databases
# ✓ No cross-tier access except defined paths
# ✓ All inbound rules whitelist specific sources
# ✓ All outbound rules allow necessary communication
# ✓ No implicit trust relationships
# ✓ Audit trail ready for CloudTrail
