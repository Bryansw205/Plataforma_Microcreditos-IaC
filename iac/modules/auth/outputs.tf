output "user_pool_id" {
  description = "ID del Pool de Usuarios Cognito"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN del Pool de Usuarios Cognito"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "URL del endpoint del Pool de Usuarios Cognito (para validación de JWT)"
  value       = aws_cognito_user_pool.main.endpoint
}

output "spa_client_id" {
  description = "ID del cliente del Pool de Usuarios Cognito para SPA (público)"
  value       = aws_cognito_user_pool_client.spa.id
}

output "backend_client_id" {
  description = "ID del cliente del Pool de Usuarios Cognito para backend (confidencial)"
  value       = aws_cognito_user_pool_client.backend.id
}

output "backend_client_secret" {
  description = "Secreto del cliente del Pool de Usuarios Cognito para backend"
  value       = aws_cognito_user_pool_client.backend.client_secret
  sensitive   = true
}

output "user_pool_domain" {
  description = "Dominio alojado de Cognito para el Pool de Usuarios (para endpoints de OAuth)"
  value       = aws_cognito_user_pool_domain.main.domain
}
