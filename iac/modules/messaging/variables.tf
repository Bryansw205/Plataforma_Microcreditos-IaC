
# Variables del Módulo de Mensajería (Amazon SQS)

variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos (ej: microcreditos-dev)"
  type        = string
}

variable "environment" {
  description = "Entorno actual de trabajo (dev, staging, prod)"
  type        = string
}

# ─────────────────────────────────────────────────────────
# Cifrado en Reposo (Seguridad – RNF 14)
# ─────────────────────────────────────────────────────────

variable "sqs_kms_key_arn" {
  description = "ARN de la llave KMS para cifrar los mensajes en reposo en ambas colas"
  type        = string
}

# ─────────────────────────────────────────────────────────
# Tiempos de la Cola Principal
# ─────────────────────────────────────────────────────────

variable "visibility_timeout_seconds" {
  description = "Tiempo en segundos que un mensaje permanece invisible tras ser leído (debe superar el tiempo de procesamiento del backend)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Tiempo máximo de retención de mensajes en la cola principal (default: 4 días = 345600s para cumplir RNF_21)"
  type        = number
  default     = 345600 # 4 días
}

variable "receive_wait_time_seconds" {
  description = "Tiempo de espera en long-polling para reducir llamadas vacías y costos (0-20s)"
  type        = number
  default     = 10
}

# ─────────────────────────────────────────────────────────
# Configuración de la DLQ (Dead Letter Queue)
# ─────────────────────────────────────────────────────────

variable "max_receive_count" {
  description = "Número máximo de reintentos antes de mover el mensaje a la DLQ"
  type        = number
  default     = 3
}

variable "dlq_retention_seconds" {
  description = "Tiempo de retención en la DLQ (default: 14 días = 1209600s, máximo permitido por SQS)"
  type        = number
  default     = 1209600 # 14 días
}
