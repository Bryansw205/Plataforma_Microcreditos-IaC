variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "La región de AWS no puede estar vacía."
  }
}

variable "project_name" {
  description = "Nombre del proyecto utilizado para identificar los recursos."
  type        = string
  default     = "microcreditos"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "El nombre del proyecto solo puede contener letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Ambiente de despliegue de la infraestructura."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El ambiente debe ser dev, staging o prod."
  }
}

variable "tags" {
  description = "Etiquetas adicionales que se aplicarán a los recursos."
  type        = map(string)
  default     = {}
}