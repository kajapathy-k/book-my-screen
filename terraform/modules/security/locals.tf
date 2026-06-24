################################################################################
# LOCAL VALUES FOR SECURITY MODULE
################################################################################
# This file defines reusable local values for naming conventions and tagging
# strategies across the security module.

locals {
  ################################################################################
  # Naming Convention
  ################################################################################
  project_name = var.project_name
  environment  = var.environment

  ################################################################################
  # Common Tagging Strategy
  ################################################################################
  # Every resource created by this module will include these tags
  common_tags = merge(
    {
      Project     = local.project_name
      Environment = local.environment
      Module      = "Security"
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  ################################################################################
  # Security Group Rule Descriptions
  ################################################################################
  # Descriptive text for audit trails and documentation
  sg_rule_descriptions = {
    alb_http              = "Allow HTTP from internet (ALB public entry point)"
    alb_https             = "Allow HTTPS from internet (ALB public entry point)"
    alb_egress            = "Allow all outbound traffic from ALB"
    
    frontend_http_alb     = "Allow HTTP from ALB to frontend (port 80)"
    frontend_https_alb    = "Allow HTTPS from ALB to frontend (port 443)"
    frontend_egress       = "Allow all outbound from frontend (updates, logging, backend API calls)"
    
    backend_frontend      = "Allow port 9000 from frontend (Node.js/Express/Socket.IO)"
    backend_egress        = "Allow all outbound from backend (DocumentDB, Redis, external APIs)"
    
    documentdb_backend    = "Allow MongoDB port 27017 from backend (DocumentDB cluster)"
    documentdb_egress     = "Allow all outbound from DocumentDB (return traffic)"
    
    redis_backend         = "Allow Redis port 6379 from backend (ElastiCache cluster)"
    redis_egress          = "Allow all outbound from Redis (return traffic)"
  }
}
