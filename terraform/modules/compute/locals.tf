################################################################################
# LOCAL VALUES FOR COMPUTE MODULE
################################################################################

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
      Module      = "Compute"
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  ################################################################################
  # Resource Naming
  ################################################################################
  alb_name               = "${local.project_name}-alb"
  frontend_tg_name       = "${local.project_name}-frontend-tg"
  backend_tg_name        = "${local.project_name}-backend-tg"
  frontend_instance_name = "${local.project_name}-frontend"
  backend_instance_name  = "${local.project_name}-backend"
}
