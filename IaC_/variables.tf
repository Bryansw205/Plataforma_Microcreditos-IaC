variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "microcreditos"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Región principal de AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloque CIDR principal de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "backend_port" {
  description = "Puerto interno del contenedor backend en ECS"
  type        = number
  default     = 3000
}

variable "database_port" {
  description = "Puerto de Aurora PostgreSQL"
  type        = number
  default     = 5432
}

variable "redis_port" {
  description = "Puerto de Redis"
  type        = number
  default     = 6379
}

variable "sqs_message_retention_seconds" {
  description = "Tiempo de retencion de mensajes en la cola principal de SQS"
  type        = number
  default     = 345600
}

variable "sqs_dlq_message_retention_seconds" {
  description = "Tiempo de retencion de mensajes en la Dead-Letter Queue"
  type        = number
  default     = 1209600
}

variable "sqs_receive_wait_time_seconds" {
  description = "Tiempo de espera para long polling en SQS"
  type        = number
  default     = 20
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tiempo durante el cual un mensaje queda oculto mientras el Worker lo procesa"
  type        = number
  default     = 60
}

variable "sqs_max_receive_count" {
  description = "Cantidad maxima de intentos antes de enviar el mensaje a la DLQ"
  type        = number
  default     = 3
}

variable "documents_retention_days" {
  description = "Dias de retencion para documentos y contratos con Object Lock"
  type        = number
  default     = 3650
}

variable "audit_retention_days" {
  description = "Dias de retencion para registros de auditoria con Object Lock"
  type        = number
  default     = 365
}