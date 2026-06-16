output "ssm_parameter_arns" {
  description = "Mapa de rutas de parámetros SSM a sus ARNs"
  value = {
    for key, param in aws_ssm_parameter.config : key => param.arn
  }
}

output "ssm_parameter_names" {
  description = "Nombres completos de todos los parámetros SSM creados"
  value = {
    for key, param in aws_ssm_parameter.config : key => param.name
  }
}

output "ssm_base_path" {
  description = "Ruta base para todos los parámetros SSM"
  value       = local.ssm_base_path
}

output "api_keys_secret_arn" {
  description = "ARN del secreto que contiene claves de APIs externas"
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "api_keys_secret_name" {
  description = "Nombre del secreto para claves de APIs"
  value       = aws_secretsmanager_secret.api_keys.name
}

output "jwt_config_secret_arn" {
  description = "ARN del secreto que contiene configuración JWT"
  value       = aws_secretsmanager_secret.jwt_config.arn
}

output "jwt_config_secret_name" {
  description = "Nombre del secreto para configuración JWT"
  value       = aws_secretsmanager_secret.jwt_config.name
}

output "database_secret_arn" {
  description = "ARN del secreto de base de datos (si está habilitado)"
  value       = var.create_database_secret ? aws_secretsmanager_secret.database[0].arn : null
}

output "database_secret_name" {
  description = "Nombre del secreto de base de datos (si está habilitado)"
  value       = var.create_database_secret ? aws_secretsmanager_secret.database[0].name : null
}