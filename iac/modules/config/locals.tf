locals {
  name_prefix = "${var.project.name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Project     = var.project.name
      Environment = var.environment
      Layer      = "configuracion"
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    }
  )
}