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

variable "alert_email" {
  description = "Correo electronico para recibir alertas SNS. Si queda vacio, no se crea suscripcion por email"
  type        = string
  default     = ""
}

variable "aurora_engine_version" {
  description = "Version del motor Aurora PostgreSQL"
  type        = string
  default     = "16.4"
}

variable "aurora_database_name" {
  description = "Nombre de la base de datos principal"
  type        = string
  default     = "microcreditos"
}

variable "aurora_master_username" {
  description = "Usuario administrador de Aurora PostgreSQL"
  type        = string
  default     = "admin_microcreditos"
}

variable "aurora_instance_class" {
  description = "Clase de instancia para Aurora PostgreSQL"
  type        = string
  default     = "db.t4g.medium"
}

variable "aurora_instance_count" {
  description = "Cantidad de instancias Aurora. Se usan 2 para tener Writer y Reader en Multi-AZ"
  type        = number
  default     = 2
}

variable "aurora_backup_retention_period" {
  description = "Dias de retencion de backups automaticos para PITR"
  type        = number
  default     = 7
}

variable "aurora_preferred_backup_window" {
  description = "Ventana preferida para backups automaticos"
  type        = string
  default     = "05:00-06:00"
}

variable "aurora_preferred_maintenance_window" {
  description = "Ventana preferida para mantenimiento"
  type        = string
  default     = "sun:06:00-sun:07:00"
}

variable "aurora_deletion_protection" {
  description = "Proteccion contra eliminacion accidental del cluster Aurora. En produccion debe ser true"
  type        = bool
  default     = false
}

variable "aurora_skip_final_snapshot" {
  description = "Omitir snapshot final al destruir. En produccion debe ser false"
  type        = bool
  default     = true
}

variable "aurora_apply_immediately" {
  description = "Aplicar cambios de Aurora inmediatamente"
  type        = bool
  default     = true
}


variable "alb_enable_deletion_protection" {
  description = "Habilitar proteccion contra borrado en el ALB"
  type        = bool
  default     = false
}

variable "alb_idle_timeout" {
  description = "Tiempo maximo en segundos de conexion inactiva en el ALB"
  type        = number
  default     = 60
}

variable "alb_deregistration_delay" {
  description = "Tiempo de espera en segundos para desregistrar un target en el ALB"
  type        = number
  default     = 30
}

variable "alb_health_check_path" {
  description = "Ruta del endpoint de health check para la API"
  type        = string
  default     = "/health"
}

variable "alb_health_check_interval" {
  description = "Intervalo en segundos entre cada health check"
  type        = number
  default     = 30
}

variable "alb_health_check_timeout" {
  description = "Tiempo de espera en segundos para que un health check se considere fallido"
  type        = number
  default     = 5
}

variable "alb_healthy_threshold" {
  description = "Cantidad de verificaciones exitosas para considerar el target sano"
  type        = number
  default     = 3
}

variable "alb_unhealthy_threshold" {
  description = "Cantidad de verificaciones fallidas para considerar el target insano"
  type        = number
  default     = 3
}

variable "alb_ssl_policy" {
  description = "Politica SSL a usar en el listener HTTPS del ALB"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}