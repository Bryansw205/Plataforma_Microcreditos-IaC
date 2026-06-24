output "project_name" {
  description = "Nombre del proyecto utilizado en la infraestructura."
  value       = var.project_name
}

output "environment" {
  description = "Ambiente donde se despliega la infraestructura."
  value       = var.environment
}

output "aws_region" {
  description = "Región de AWS configurada para el despliegue."
  value       = var.aws_region
}

output "name_prefix" {
  description = "Prefijo común utilizado para nombrar los recursos."
  value       = local.name_prefix
}

output "common_tags" {
  description = "Etiquetas comunes aplicadas a los recursos."
  value       = local.common_tags
}