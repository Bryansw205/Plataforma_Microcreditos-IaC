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