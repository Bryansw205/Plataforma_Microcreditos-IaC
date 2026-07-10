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
  default     = true
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
  description = "Habilita proteccion contra eliminacion accidental del Application Load Balancer"
  type        = bool
  default     = true
}

variable "alb_idle_timeout" {
  description = "Tiempo maximo de inactividad de una conexion en el ALB"
  type        = number
  default     = 60
}

variable "alb_deregistration_delay" {
  description = "Tiempo de espera para retirar una tarea del Target Group durante el drenado de conexiones"
  type        = number
  default     = 30
}

variable "alb_health_check_path" {
  description = "Ruta usada por el Target Group para comprobar la salud del ECS API Service"
  type        = string
  default     = "/actuator/health"
}

variable "alb_health_check_interval" {
  description = "Intervalo de comprobacion de salud del Target Group"
  type        = number
  default     = 30
}

variable "alb_health_check_timeout" {
  description = "Tiempo maximo de espera para cada comprobacion de salud"
  type        = number
  default     = 5
}

variable "alb_healthy_threshold" {
  description = "Cantidad de comprobaciones exitosas para considerar saludable una tarea"
  type        = number
  default     = 2
}

variable "alb_unhealthy_threshold" {
  description = "Cantidad de comprobaciones fallidas para considerar no saludable una tarea"
  type        = number
  default     = 2
}

variable "alb_ssl_policy" {
  description = "Politica TLS utilizada por el listener HTTPS del ALB"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

# ============================================================
# ECS Fargate Variables (Basado en el documento de Arquitectura)
# ============================================================

variable "ecs_api_cpu" {
  description = "CPU units para el contenedor de la API (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "ecs_api_memory" {
  description = "Memoria en MB para el contenedor de la API"
  type        = number
  default     = 1024
}

variable "ecs_worker_cpu" {
  description = "CPU units para el contenedor Worker"
  type        = number
  default     = 512
}

variable "ecs_worker_memory" {
  description = "Memoria en MB para el contenedor Worker"
  type        = number
  default     = 1024
}

variable "ecs_api_min_capacity" {
  description = "Capacidad minima de tareas para la API (Para HA)"
  type        = number
  default     = 2
}

variable "ecs_api_max_capacity" {
  description = "Capacidad maxima de tareas para la API"
  type        = number
  default     = 10
}

variable "ecs_scale_cpu_threshold" {
  description = "Porcentaje de CPU para disparar el Auto Scaling de ECS (RNF_11)"
  type        = number
  default     = 70
}

variable "ecs_scale_memory_threshold" {
  description = "Porcentaje de memoria para disparar el Auto Scaling de ECS (RNF_11)"
  type        = number
  default     = 70
}

# ============================================================
# Security & Observability Variables (Basado en el documento RNF)
# ============================================================

variable "cognito_jwt_validity_minutes" {
  description = "Tiempo maximo de vigencia de tokens JWT (RNF_17)"
  type        = number
  default     = 15
}

variable "waf_rate_limit" {
  description = "Limite de peticiones por 5 minutos por IP antes de bloquear (RNF_15). Nota: AWS WAFv2 requiere un minimo de 100."
  type        = number
  default     = 100
}

variable "alarm_cpu_threshold" {
  description = "Porcentaje de CPU critico para enviar alerta (RNF_26)"
  type        = number
  default     = 85
}

variable "alarm_memory_threshold" {
  description = "Porcentaje de memoria critico para enviar alerta (RNF_26)"
  type        = number
  default     = 85
}

variable "api_image_uri" {
  description = "Imagen Docker de la API. Si queda vacio, se usa el repositorio ECR creado por Terraform con tag latest"
  type        = string
  default     = ""
}

variable "worker_image_uri" {
  description = "Imagen Docker del Worker. Si queda vacio, se usa el repositorio ECR creado por Terraform con tag latest"
  type        = string
  default     = ""
}

variable "ecs_worker_min_capacity" {
  description = "Cantidad minima de tareas del Worker"
  type        = number
  default     = 1
}

variable "ecs_worker_max_capacity" {
  description = "Cantidad maxima de tareas del Worker"
  type        = number
  default     = 5
}

variable "ecs_worker_queue_messages_target" {
  description = "Cantidad objetivo de mensajes visibles en SQS para escalar el Worker"
  type        = number
  default     = 10
}

variable "ecs_health_check_grace_period_seconds" {
  description = "Tiempo de gracia para que ECS espere antes de evaluar health checks del ALB"
  type        = number
  default     = 60
}

variable "ecs_enable_execute_command" {
  description = "Habilita ECS Exec para diagnostico controlado"
  type        = bool
  default     = false
}