# ============================================================
# Outputs Raíz – Plataforma de Microcréditos
# ============================================================

# ─────────────────────────────────────────────────────────────
# Generales
# ─────────────────────────────────────────────────────────────

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

# ─────────────────────────────────────────────────────────────
# Networking
# ─────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID de la VPC principal."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "Bloque CIDR de la VPC."
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas."
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs de las subredes privadas de aplicación."
  value       = module.networking.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "IDs de las subredes privadas de datos."
  value       = module.networking.private_data_subnet_ids
}

# ─────────────────────────────────────────────────────────────
# Security
# ─────────────────────────────────────────────────────────────

output "alb_security_group_id" {
  description = "Security Group ID del Application Load Balancer."
  value       = module.security.alb_security_group_id
}

output "backend_security_group_id" {
  description = "Security Group ID del backend ECS/Fargate."
  value       = module.security.backend_security_group_id
}

output "database_security_group_id" {
  description = "Security Group ID de la base de datos."
  value       = module.security.database_security_group_id
}

output "redis_security_group_id" {
  description = "Security Group ID de ElastiCache Redis."
  value       = module.security.redis_security_group_id
}

output "kms_key_arn" {
  description = "ARN de la llave KMS principal."
  value       = module.security.kms_key_arn
}

# ─────────────────────────────────────────────────────────────
# Database
# ─────────────────────────────────────────────────────────────

output "db_endpoint" {
  description = "Endpoint de conexión de la base de datos (Host:Puerto)."
  value       = module.database.db_endpoint
}

output "db_secret_arn" {
  description = "ARN del secreto en Secrets Manager con las credenciales de la BD."
  value       = module.database.db_secret_arn
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS PostgreSQL."
  value       = module.database.db_instance_arn
}

# ─────────────────────────────────────────────────────────────
# Storage
# ─────────────────────────────────────────────────────────────

output "documents_bucket_id" {
  description = "Nombre del bucket S3 de documentos."
  value       = module.storage.documents_bucket_id
}

output "documents_bucket_arn" {
  description = "ARN del bucket S3 de documentos."
  value       = module.storage.documents_bucket_arn
}

# ─────────────────────────────────────────────────────────────
# Cache
# ─────────────────────────────────────────────────────────────

output "redis_endpoint" {
  description = "Endpoint del nodo primario de Redis."
  value       = module.cache.redis_endpoint
}

# ─────────────────────────────────────────────────────────────
# Auth (Cognito)
# ─────────────────────────────────────────────────────────────

output "cognito_user_pool_id" {
  description = "ID del Pool de Usuarios Cognito."
  value       = module.auth.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN del Pool de Usuarios Cognito."
  value       = module.auth.user_pool_arn
}

output "cognito_user_pool_endpoint" {
  description = "URL del endpoint de Cognito (para validación de JWT)."
  value       = module.auth.user_pool_endpoint
}

output "cognito_spa_client_id" {
  description = "ID del cliente Cognito para SPA (público)."
  value       = module.auth.spa_client_id
}

output "cognito_backend_client_id" {
  description = "ID del cliente Cognito para backend (confidencial)."
  value       = module.auth.backend_client_id
}

# ─────────────────────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────────────────────

output "ssm_base_path" {
  description = "Ruta base para todos los parámetros SSM."
  value       = module.config.ssm_base_path
}

output "api_keys_secret_arn" {
  description = "ARN del secreto que contiene claves de APIs externas."
  value       = module.config.api_keys_secret_arn
}

output "jwt_config_secret_arn" {
  description = "ARN del secreto que contiene configuración JWT."
  value       = module.config.jwt_config_secret_arn
}

# ─────────────────────────────────────────────────────────────
# Messaging
# ─────────────────────────────────────────────────────────────

output "sqs_queue_url" {
  description = "URL de la cola SQS principal."
  value       = module.messaging.queue_id
}

output "sqs_queue_arn" {
  description = "ARN de la cola SQS principal."
  value       = module.messaging.queue_arn
}

output "sqs_dlq_url" {
  description = "URL de la Dead Letter Queue."
  value       = module.messaging.dlq_id
}

# ─────────────────────────────────────────────────────────────
# CDN
# ─────────────────────────────────────────────────────────────

output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront."
  value       = module.cdn.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "Dominio asignado por CloudFront."
  value       = module.cdn.cloudfront_domain_name
}

# ─────────────────────────────────────────────────────────────
# Backup
# ─────────────────────────────────────────────────────────────

output "backup_vault_name" {
  description = "Nombre de la bóveda de respaldos de AWS Backup."
  value       = module.backup.backup_vault_name
}

output "backup_plan_id" {
  description = "ID del plan de respaldo diario."
  value       = module.backup.backup_plan_id
}

# ─────────────────────────────────────────────────────────────
# Observability
# ─────────────────────────────────────────────────────────────

output "sns_alerts_topic_arn" {
  description = "ARN del topic SNS para alertas críticas."
  value       = module.observability.sns_topic_arn
}

output "ecs_log_group_name" {
  description = "Nombre del Log Group de ECS."
  value       = module.observability.ecs_log_group_name
}