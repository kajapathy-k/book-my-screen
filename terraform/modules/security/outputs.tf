################################################################################
# SECURITY MODULE OUTPUTS
################################################################################
# These outputs expose security group resource identifiers for consumption
# by other modules in Phase 2+ (EC2, ALB, DocumentDB, ElastiCache, etc.)

################################################################################
# ALB SECURITY GROUP OUTPUTS
################################################################################

output "alb_security_group_id" {
  description = "The ID of the ALB Security Group"
  value       = aws_security_group.alb.id
}

output "documentdb_sg_id" {
  description = "DocumentDB security group ID"
  value       = aws_security_group.documentdb.id
}


output "alb_security_group_name" {
  description = "The name of the ALB Security Group"
  value       = aws_security_group.alb.name
}

output "alb_security_group_arn" {
  description = "The ARN of the ALB Security Group"
  value       = aws_security_group.alb.arn
}

################################################################################
# FRONTEND SECURITY GROUP OUTPUTS
################################################################################

output "frontend_security_group_id" {
  description = "The ID of the Frontend Security Group"
  value       = aws_security_group.frontend.id
}

output "frontend_security_group_name" {
  description = "The name of the Frontend Security Group"
  value       = aws_security_group.frontend.name
}

output "frontend_security_group_arn" {
  description = "The ARN of the Frontend Security Group"
  value       = aws_security_group.frontend.arn
}

################################################################################
# BACKEND SECURITY GROUP OUTPUTS
################################################################################

output "backend_security_group_id" {
  description = "The ID of the Backend Security Group"
  value       = aws_security_group.backend.id
}

output "backend_security_group_name" {
  description = "The name of the Backend Security Group"
  value       = aws_security_group.backend.name
}

output "backend_security_group_arn" {
  description = "The ARN of the Backend Security Group"
  value       = aws_security_group.backend.arn
}

################################################################################
# DOCUMENTDB SECURITY GROUP OUTPUTS
################################################################################

output "documentdb_security_group_id" {
  description = "The ID of the DocumentDB Security Group"
  value       = aws_security_group.documentdb.id
}

output "documentdb_security_group_name" {
  description = "The name of the DocumentDB Security Group"
  value       = aws_security_group.documentdb.name
}

output "documentdb_security_group_arn" {
  description = "The ARN of the DocumentDB Security Group"
  value       = aws_security_group.documentdb.arn
}

################################################################################
# REDIS SECURITY GROUP OUTPUTS
################################################################################

output "redis_security_group_id" {
  description = "The ID of the Redis Security Group"
  value       = aws_security_group.redis.id
}

output "redis_security_group_name" {
  description = "The name of the Redis Security Group"
  value       = aws_security_group.redis.name
}

output "redis_security_group_arn" {
  description = "The ARN of the Redis Security Group"
  value       = aws_security_group.redis.arn
}

################################################################################
# SECURITY ARCHITECTURE SUMMARY OUTPUTS
################################################################################

output "security_groups_summary" {
  description = "Summary of all security groups created"
  value = {
    alb = {
      id   = aws_security_group.alb.id
      name = aws_security_group.alb.name
      vpc  = aws_security_group.alb.vpc_id
    }
    frontend = {
      id   = aws_security_group.frontend.id
      name = aws_security_group.frontend.name
      vpc  = aws_security_group.frontend.vpc_id
    }
    backend = {
      id   = aws_security_group.backend.id
      name = aws_security_group.backend.name
      vpc  = aws_security_group.backend.vpc_id
    }
    documentdb = {
      id   = aws_security_group.documentdb.id
      name = aws_security_group.documentdb.name
      vpc  = aws_security_group.documentdb.vpc_id
    }
    redis = {
      id   = aws_security_group.redis.id
      name = aws_security_group.redis.name
      vpc  = aws_security_group.redis.vpc_id
    }
  }
}

output "security_architecture_diagram" {
  description = "Traffic flow architecture"
  value = {
    flow = "Internet → ALB → Frontend → Backend → (DocumentDB | Redis)"
    principle = "Least Privilege - Each tier only accepts from tier above"
    isolation = "No direct access from Internet to Backend or Data layers"
  }
}
