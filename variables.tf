variable "project_name" {
  description = "Nombre del proyecto de microcréditos."
  type        = string
  default     = "microcreditos"
}

variable "environment" {
  description = "Ambiente donde se desplegará la infraestructura."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "El ambiente debe ser dev, test o prod."
  }
}

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura."
  type        = string
  default     = "us-east-1"
}

variable "app_port" {
  description = "Puerto interno donde escuchará el backend."
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "Imagen Docker inicial para el backend."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:latest"
}