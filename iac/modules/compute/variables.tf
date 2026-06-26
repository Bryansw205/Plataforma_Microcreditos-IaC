variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "environment" {
  description = "Entorno actual (dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegarán los recursos"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de IDs de subredes públicas (para el ALB)"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "Lista de IDs de subredes privadas (para ECS Fargate)"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID del Security Group de las tareas ECS"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN del certificado SSL/TLS de AWS Certificate Manager para el ALB"
  type        = string
}

variable "ecr_image_uri" {
  description = "URI de la imagen del contenedor en Amazon ECR"
  type        = string
  default     = "nginx:latest" # Placeholder por defecto
}

variable "container_port" {
  description = "Puerto interno expuesto por el contenedor"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU asignada a la tarea Fargate (ej. 256)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memoria asignada a la tarea Fargate (ej. 512)"
  type        = number
  default     = 512
}

variable "secrets_kms_key_arn" {
  description = "ARN de la llave KMS utilizada para los secretos (para dar permisos a ECS)"
  type        = string
}
