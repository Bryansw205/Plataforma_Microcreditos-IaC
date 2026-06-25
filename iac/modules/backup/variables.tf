
# Variables del Módulo de Respaldo (AWS Backup)

variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos (ej: microcreditos-dev)"
  type        = string
}

variable "environment" {
  description = "Entorno actual de trabajo (dev, staging, prod)"
  type        = string
}

# ─────────────────────────────────────────────────────────
# ARNs de los recursos a proteger
# ─────────────────────────────────────────────────────────

variable "rds_instance_arn" {
  description = "ARN de la instancia RDS PostgreSQL que será respaldada por AWS Backup"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3 de documentos y evidencias legales a respaldar"
  type        = string
}

variable "backup_kms_key_arn" {
  description = "ARN de la llave KMS para el cifrado en reposo de la bóveda"
  type        = string
}

# ─────────────────────────────────────────────────────────
# Configuración de Frecuencia y Retención
# ─────────────────────────────────────────────────────────

variable "backup_schedule" {
  description = "Expresión cron de AWS para la frecuencia del respaldo (por defecto: diario a las 3:00 AM UTC)"
  type        = string
  default     = "cron(0 3 * * ? *)" # 3:00 AM UTC = ~10:00 PM hora Perú (UTC-5)
}

variable "backup_retention_days" {
  description = "Número de días que se conservarán los puntos de recuperación"
  type        = number
  default     = 7
}

variable "backup_window_minutes" {
  description = "Duración máxima en minutos de la ventana de respaldo antes de cancelarse"
  type        = number
  default     = 120
}
