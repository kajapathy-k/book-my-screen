################################################################################
# COMPUTE MODULE OUTPUTS
################################################################################

################################################################################
# ALB OUTPUTS
################################################################################

output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer for accessing the application"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The Zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

################################################################################
# TARGET GROUP OUTPUTS
################################################################################

output "frontend_target_group_arn" {
  description = "The ARN of the Frontend Target Group"
  value       = aws_lb_target_group.frontend.arn
}

output "frontend_target_group_name" {
  description = "The name of the Frontend Target Group"
  value       = aws_lb_target_group.frontend.name
}

output "backend_target_group_arn" {
  description = "The ARN of the Backend Target Group"
  value       = aws_lb_target_group.backend.arn
}

output "backend_target_group_name" {
  description = "The name of the Backend Target Group"
  value       = aws_lb_target_group.backend.name
}

################################################################################
# LISTENER OUTPUTS
################################################################################

output "http_listener_arn" {
  description = "The ARN of the HTTP Listener"
  value       = aws_lb_listener.http.arn
}

output "api_listener_rule_arn" {
  description = "The ARN of the /api/* Listener Rule"
  value       = aws_lb_listener_rule.api.arn
}

################################################################################
# FRONTEND EC2 OUTPUTS
################################################################################

output "frontend_instance_id" {
  description = "The ID of the Frontend EC2 instance"
  value       = aws_instance.frontend.id
}

output "frontend_instance_arn" {
  description = "The ARN of the Frontend EC2 instance"
  value       = aws_instance.frontend.arn
}

output "frontend_private_ip" {
  description = "The private IP address of the Frontend EC2 instance"
  value       = aws_instance.frontend.private_ip
}

output "frontend_availability_zone" {
  description = "The Availability Zone of the Frontend EC2 instance"
  value       = aws_instance.frontend.availability_zone
}

output "frontend_security_group_ids" {
  description = "The security group IDs assigned to Frontend EC2"
  value       = aws_instance.frontend.vpc_security_group_ids
}

################################################################################
# BACKEND EC2 OUTPUTS
################################################################################

output "backend_instance_id" {
  description = "The ID of the Backend EC2 instance"
  value       = aws_instance.backend.id
}

output "backend_instance_arn" {
  description = "The ARN of the Backend EC2 instance"
  value       = aws_instance.backend.arn
}

output "backend_private_ip" {
  description = "The private IP address of the Backend EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "backend_availability_zone" {
  description = "The Availability Zone of the Backend EC2 instance"
  value       = aws_instance.backend.availability_zone
}

output "backend_security_group_ids" {
  description = "The security group IDs assigned to Backend EC2"
  value       = aws_instance.backend.vpc_security_group_ids
}

################################################################################
# TESTING & ACCESS INFORMATION
################################################################################

output "application_access_url" {
  description = "URL to access the BookMyScreen application via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "testing_information" {
  description = "Information for testing the application"
  value = {
    alb_dns_name           = aws_lb.main.dns_name
    alb_url                = "http://${aws_lb.main.dns_name}"
    frontend_health_check  = "http://${aws_lb.main.dns_name}/"
    backend_health_check   = "http://${aws_lb.main.dns_name}/api/v1"
    api_endpoint           = "http://${aws_lb.main.dns_name}/api"
    frontend_instance_id   = aws_instance.frontend.id
    frontend_private_ip    = aws_instance.frontend.private_ip
    backend_instance_id    = aws_instance.backend.id
    backend_private_ip     = aws_instance.backend.private_ip
    alb_health_check_delay = "2-3 minutes (wait for targets to become healthy)"
  }
}

################################################################################
# SUMMARY OUTPUT
################################################################################

output "compute_architecture_summary" {
  description = "Summary of compute architecture"
  value = {
    load_balancer = {
      name              = aws_lb.main.name
      arn               = aws_lb.main.arn
      dns_name          = aws_lb.main.dns_name
      subnets           = aws_lb.main.subnets
      security_groups   = aws_lb.main.security_groups
      scheme            = "internet-facing"
      type              = "application"
    }
    target_groups = {
      frontend = {
        name     = aws_lb_target_group.frontend.name
        port     = aws_lb_target_group.frontend.port
        protocol = aws_lb_target_group.frontend.protocol
        vpc_id   = aws_lb_target_group.frontend.vpc_id
      }
      backend = {
        name     = aws_lb_target_group.backend.name
        port     = aws_lb_target_group.backend.port
        protocol = aws_lb_target_group.backend.protocol
        vpc_id   = aws_lb_target_group.backend.vpc_id
      }
    }
    instances = {
      frontend = {
        instance_id    = aws_instance.frontend.id
        instance_type  = aws_instance.frontend.instance_type
        ami            = aws_instance.frontend.ami
        availability_zone = aws_instance.frontend.availability_zone
        private_ip     = aws_instance.frontend.private_ip
        subnet_id      = aws_instance.frontend.subnet_id
        security_groups = aws_instance.frontend.vpc_security_group_ids
      }
      backend = {
        instance_id    = aws_instance.backend.id
        instance_type  = aws_instance.backend.instance_type
        ami            = aws_instance.backend.ami
        availability_zone = aws_instance.backend.availability_zone
        private_ip     = aws_instance.backend.private_ip
        subnet_id      = aws_instance.backend.subnet_id
        security_groups = aws_instance.backend.vpc_security_group_ids
      }
    }
  }
}
