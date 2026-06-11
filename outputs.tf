output "project_name" {
  description = "Nombre del proyecto."
  value       = var.project_name
}

output "environment" {
  description = "Ambiente configurado."
  value       = var.environment
}

output "aws_region" {
  description = "Región de AWS configurada."
  value       = var.aws_region
}

output "current_region" {
  description = "Región actual obtenida desde el proveedor AWS."
  value       = data.aws_region.current.name
}

output "name_prefix" {
  description = "Prefijo estándar para nombrar recursos."
  value       = local.name_prefix
}