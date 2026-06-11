locals {
  name_prefix = "${var.project.name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Project     = var.project.name
      Environment = var.environment
      Layer      = "autenticacion"
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    }
  )
}