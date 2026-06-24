locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Layer       = "security"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}