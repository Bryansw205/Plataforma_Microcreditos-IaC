variable "project_name" {
  description = "Nombre del proyecto. Se usará como prefijo para nombrar recursos."
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name no puede estar vacío."
  }
}

variable "environment" {
  description = "Ambiente de despliegue: dev, staging, prod"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment debe ser uno de: dev, staging, prod."
  }
}

variable "domain_name" {
  description = "Nombre de dominio principal para la aplicación (ej: microcreditos.example.com)"
  type        = string

  validation {
    condition     =  length(var.domain_name) > 0
    error_message = "domain_name debe ser un nombre de dominio válido."
  }
}

variable "enable_deletion_protection" {
  description = "Habilitar protección de eliminación para el Pool de Usuarios (recomendado para prod)"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN o ID de la clave KMS para encriptar tokens y datos sensibles. Si no se proporciona, se usa encriptación AWS-managed"
  type        = string
  default     = null
}

variable "password_minimum_length" {
  description = "Longitud mínima de contraseña (8-128 caracteres)"
  type        = number
  default     = 12

  validation {
    condition     = var.password_minimum_length >= 8 && var.password_minimum_length <= 128
    error_message = "password_minimum_length debe estar entre 8 y 128 caracteres."
  }
}

variable "password_require_symbols" {
  description = "Requerir caracteres especiales en contraseñas"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Días de validez para contraseñas temporales (1-365 días)"
  type        = number
  default     = 7

  validation {
    condition     = var.temporary_password_validity_days >= 1 && var.temporary_password_validity_days <= 365
    error_message = "temporary_password_validity_days debe estar entre 1 y 365 días."
  }
}


variable "access_token_validity_minutes" {
  description = "Validez del token de acceso en minutos (5-24 horas = 5-1440 minutos)"
  type        = number
  default     = 15

  validation {
    condition     = var.access_token_validity_minutes >= 5 && var.access_token_validity_minutes <= 1440
    error_message = "access_token_validity_minutes debe estar entre 5 y 1440 minutos."
  }
}

variable "refresh_token_validity_hours" {
  description = "Validez del token de refresco en horas (24 horas a 10 años)"
  type        = number
  default     = 24

  validation {
    condition     = var.refresh_token_validity_hours >= 24 && var.refresh_token_validity_hours <= 87600
    error_message = "refresh_token_validity_hours debe estar entre 24 horas y 10 años (87600 horas)."
  }
}

variable "allow_username_password_auth" {
  description = "Permitir autenticación directa con usuario y contraseña (menos seguro, no recomendado)"
  type        = bool
  default     = false
}


variable "spa_callback_urls" {
  description = "URLs de callback válidas para el cliente SPA"
  type        = list(string)
  default     = []
}

variable "spa_logout_urls" {
  description = "URLs de logout válidas para el cliente SPA"
  type        = list(string)
  default     = []
}

variable "backend_callback_urls" {
  description = "URLs de callback válidas para el cliente Backend (opcional si usa solo admin auth)"
  type        = list(string)
  default     = []
}


variable "custom_attributes" {
  description = "Atributos personalizados adicionales para el pool de usuarios"
  type = list(object({
    name     = string
    type     = string
    required = bool
    mutable  = bool
  }))
  default = []
}


variable "tags" {
  description = "Etiquetas adicionales para aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}
