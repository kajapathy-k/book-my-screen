################################################################################
# LOCAL VALUES FOR NETWORKING MODULE
################################################################################
# This file defines reusable local values for naming conventions and tagging
# strategies across the networking module.

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
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}
