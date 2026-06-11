output "db_instance_id" {
  description = "Identificador de la instancia de base de datos"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "Endpoint de conexion de la base de datos (Host:Puerto)"
  value       = aws_db_instance.main.endpoint
}

output "db_secret_arn" {
  description = "ARN del secreto guardado en Secrets Manager con las contraseñas generadas"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
