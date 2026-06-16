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

variable "tags" {
  description = "Etiquetas adicionales para aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}

variable "secrets_kms_key_arn" {
  description = "ARN de la clave KMS para encriptar Secrets Manager. Si es null, usa encriptación AWS-managed"
  type        = string
  default     = null
}

variable "flow_api_url" {
  description = "URL base de la API de Flow (gateway de pagos)"
  type        = string
# default     = "https://api.flow.cl/v1"
}

variable "infocorp_api_url" {
  description = "URL base de la API de Infocorp (buró de crédito)"
  type        = string
# default     = "https://api.infocorp.com.pe/v1"
}

variable "max_credit_amount" {
  description = "Monto máximo de crédito permitido (en moneda local)"
  type        = number
  default     = 50000

  validation {
    condition     = var.max_credit_amount > 0
    error_message = "max_credit_amount debe ser mayor a 0."
  }
}

variable "min_credit_amount" {
  description = "Monto mínimo de crédito permitido (en moneda local)"
  type        = number
  default     = 500

  validation {
    condition     = var.min_credit_amount > 0
    error_message = "min_credit_amount debe ser mayor a 0."
  }
}

variable "interest_rates" {
  description = "Tasas de interés por plazo (ej: 12_months, 24_months, 36_months)"
  type        = map(number)
  default = {
    "12_months" = 0.15
    "24_months" = 0.18
    "36_months" = 0.22
  }

  validation {
    condition     = alltrue([for rate in values(var.interest_rates) : rate >= 0.01 && rate <= 1.00])
    error_message = "Todas las tasas deben estar entre 1% y 100%."
  }
}

variable "business_rules" {
  description = "Reglas de negocio para evaluación de créditos"
  type = object({
    max_debt_ratio = number
    min_age        = number
    max_age        = number
    min_income     = number
  })

  default = {
    max_debt_ratio = 0.40
    min_age        = 18
    max_age        = 70
    min_income     = 1000
  }
}

variable "simulation_params" {
  description = "Parámetros para simulación de créditos"
  type = object({
    max_simulations_per_day = number
    simulation_ttl_hours    = number
  })

  default = {
    max_simulations_per_day = 10
    simulation_ttl_hours    = 24
  }
}

variable "jwt_expiry_hours" {
  description = "Horas de expiración para tokens JWT de acceso"
  type        = number
  default     = 24

  validation {
    condition     = var.jwt_expiry_hours > 0 && var.jwt_expiry_hours <= 730
    error_message = "jwt_expiry_hours debe estar entre 1 y 730 horas."
  }
}

variable "jwt_refresh_expiry_days" {
  description = "Días de expiración para tokens JWT de refresco"
  type        = number
  default     = 30

  validation {
    condition     = var.jwt_refresh_expiry_days > 0
    error_message = "jwt_refresh_expiry_days debe ser mayor a 0."
  }
}

variable "log_level" {
  description = "Nivel de logging: DEBUG, INFO, WARN, ERROR"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "log_level debe ser: DEBUG, INFO, WARN, o ERROR."
  }
}

variable "log_retention_days" {
  description = "Días de retención para logs en CloudWatch"
  type        = number
  default     = 30
}

variable "create_database_secret" {
  description = "Crear secreto para credenciales de base de datos"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "microcreditos"
}
