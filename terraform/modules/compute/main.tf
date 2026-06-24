################################################################################
# AWS Compute Resources - BookMyScreen Phase 3 Application Testing
################################################################################
# This module creates an Internet-facing Application Load Balancer and EC2
# instances for testing the complete BookMyScreen application within the VPC.
#
# Architecture:
#   Internet → ALB (Public Subnets) → Frontend EC2 (Private App Subnet A)
#                                  → Backend EC2 (Private App Subnet A)
#
# Purpose:
#   - Validate ALB routing
#   - Test Frontend ↔ Backend communication
#   - Verify Security Groups
#   - Validate private subnet design
#   - End-to-end application testing

################################################################################
# APPLICATION LOAD BALANCER
################################################################################
# Internet-facing ALB distributed across public subnets for high availability
# Uses existing bms-alb-sg security group (Phase 2)

resource "aws_lb" "main" {
  name               = "${local.project_name}-alb"
  internal           = false  # Internet-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-alb"
    }
  )
}

################################################################################
# FRONTEND TARGET GROUP
################################################################################
# Target group for React/Vite frontend application on port 5173
# Health check on / path for application readiness

resource "aws_lb_target_group" "frontend" {
  name        = "${local.project_name}-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-frontend-tg"
    }
  )
}

################################################################################
# BACKEND TARGET GROUP
################################################################################
# Target group for Node.js/Express backend API on port 9000
# Health check on /api/v1 path for API readiness

resource "aws_lb_target_group" "backend" {
  name        = "${local.project_name}-backend-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 5
  interval            = 30
  path                = "/"
  protocol            = "HTTP"
  matcher             = "200-299"
}

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-backend-tg"
    }
  )
}

################################################################################
# ALB LISTENER - HTTP PORT 80
################################################################################
# Default action: Forward all traffic to Frontend Target Group
# Listener rules will route /api/* to Backend Target Group

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

################################################################################
# LISTENER RULE - /api/* ROUTING
################################################################################
# Route /api/* path pattern to Backend Target Group
# Allows frontend to call backend APIs through ALB

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

################################################################################
# FRONTEND EC2 INSTANCE
################################################################################
# Ubuntu Server running React/Vite frontend application
# Placed in Private App Subnet A (no public IP for security)
# Uses existing Frontend Security Group (Phase 2)

resource "aws_instance" "frontend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = var.frontend_private_subnets[0]
  vpc_security_group_ids = [var.frontend_sg_id]

  # Disable public IP (instance is in private subnet)
  associate_public_ip_address = false

  # Storage configuration
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = false  # Can enable with KMS key (Phase 4)
  }

  # IMDSv2 - Required for secure metadata access
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Force IMDSv2
    http_put_response_hop_limit = 1
  }

  # Monitoring (CloudWatch disabled in Phase 3)
  monitoring = false

  # User data: Install prerequisites with backend IP for nginx proxy
  user_data = base64encode(templatefile("${path.module}/user_data_frontend.sh", {
    backend_private_ip = aws_instance.backend.private_ip
  }))

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-frontend"
    }
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.main]
}

################################################################################
# BACKEND EC2 INSTANCE
################################################################################
# Ubuntu Server running Node.js/Express backend API
# Placed in Private App Subnet A (no public IP for security)
# Uses existing Backend Security Group (Phase 2)

resource "aws_instance" "backend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = var.frontend_private_subnets[0]  # Same subnet as frontend
  vpc_security_group_ids = [var.backend_sg_id]

  # Disable public IP (instance is in private subnet)
  associate_public_ip_address = false

  # Storage configuration
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = false  # Can enable with KMS key (Phase 4)
  }

  # IMDSv2 - Required for secure metadata access
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Force IMDSv2
    http_put_response_hop_limit = 1
  }

  # Monitoring (CloudWatch disabled in Phase 3)
  monitoring = false

  # User data: Install prerequisites (placeholder)
  user_data = base64encode(templatefile("${path.module}/user_data_backend.sh", { db_private_ip = aws_instance.database_instance.private_ip }))

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-backend"
    }
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.main]
}

################################################################################
# TARGET GROUP ATTACHMENTS
################################################################################
# Register instances with their respective target groups

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend.id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend.id
  port             = 9000
}

################################################################################
# TESTING & VERIFICATION NOTES
################################################################################
#
# Phase 3 Application Testing Architecture:
#
# 1. ALB DNS Name: Will be available in terraform outputs
#    - Use this to access the application from browser
#    - ALB handles routing to Frontend and Backend
#
# 2. Frontend EC2: React/Vite app on port 5173
#    - Health check: GET / returns 200-299
#    - Serves static SPA to browser
#    - Makes API calls to Backend via ALB
#
# 3. Backend EC2: Node.js/Express API on port 9000
#    - Health check: GET /api/v1 returns 200-299
#    - Exposes REST API endpoints
#    - Connected to (future) DocumentDB and Redis
#
# 4. Security Groups (Existing - Phase 2):
#    - ALB SG: HTTP 80 from 0.0.0.0/0
#    - Frontend SG: HTTP 80/443 from ALB SG
#    - Backend SG: TCP 9000 from Frontend SG
#
# 5. Testing Flow:
#    a) Wait for ALB health checks (2-3 minutes)
#    b) Access ALB DNS name in browser
#    c) Frontend loads and makes API calls to Backend
#    d) Verify BookMyScreen application functionality
#
# 6. Future Phases:
#    - Phase 3 Beta: Deploy actual application via user data
#    - Phase 4: Add DocumentDB and ElastiCache
#    - Phase 5: Add IAM roles and secrets management
#    - Phase 6: Add auto-scaling and advanced monitoring

resource "aws_instance" "database_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.backend_private_subnets[0]
  vpc_security_group_ids = [var.documentdb_sg_id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash

              apt update -y
              apt install -y docker.io awscli jq

              systemctl start docker
              systemctl enable docker

              docker run -d \
                --name mongodb \
                --restart unless-stopped \
                -p 27017:27017 \
                mongo
              EOF

  tags = merge(var.tags, {
    Name = "${var.project_name}-Database-Instance"
  })
}