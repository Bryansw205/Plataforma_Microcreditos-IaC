variable "project" {
  type        = string
  description = "Nombre del proyecto."
}

variable "environment" {
  type        = string
  description = "Ambiente de despliegue: dev, test o prod."
}

variable "notification_email" {
  type        = string
  description = "Correo del equipo de soporte para recibir alertas SNS."
}

variable "ecs_cluster_name" {
  type        = string
  description = "Nombre del cluster ECS a monitorear."
}

variable "ecs_service_name" {
  type        = string
  description = "Nombre del servicio ECS a monitorear."
}

variable "alb_arn_suffix" {
  type        = string
  description = "ARN suffix del Application Load Balancer."
}

variable "target_group_arn_suffix" {
  type        = string
  description = "ARN suffix del Target Group del ALB."
}

variable "log_retention_days" {
  type        = number
  description = "Días de retención de logs en CloudWatch."
  default     = 30
}