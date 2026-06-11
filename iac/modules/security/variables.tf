variable "project_name" {
  description = "Nombre del proyecto. Se usará como prefijo para nombrar recursos."
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name no puede estar vacío."
  }
}

variable "environment" {
  description = "Ambiente donde se desplegará la infraestructura: dev, staging o prod."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment debe ser dev, staging o prod."
  }
}

variable "vpc_id" {
  description = "ID de la VPC creada por la capa de networking."
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "vpc_id debe ser un ID válido de VPC, por ejemplo vpc-xxxxxxxx."
  }
}

variable "backend_port" {
  description = "Puerto donde escuchará el backend en ECS/Fargate."
  type        = number
  default     = 8080

  validation {
    condition     = var.backend_port > 0 && var.backend_port <= 65535
    error_message = "backend_port debe estar entre 1 y 65535."
  }
}

variable "database_port" {
  description = "Puerto de la base de datos PostgreSQL/Aurora."
  type        = number
  default     = 5432
}

variable "redis_port" {
  description = "Puerto de Redis en ElastiCache."
  type        = number
  default     = 6379
}

variable "allowed_http_cidr_blocks" {
  description = "CIDR permitidos para tráfico HTTP hacia el ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidr_blocks" {
  description = "CIDR permitidos para tráfico HTTPS hacia el ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "blocked_ip_addresses" {
  description = "Lista de IPs o rangos CIDR que serán bloqueados por AWS WAF."
  type        = list(string)
  default     = []
}

variable "enable_regional_waf" {
  description = "Habilita AWS WAF regional para proteger el Application Load Balancer."
  type        = bool
  default     = true
}

variable "enable_cloudfront_waf" {
  description = "Habilita AWS WAF global para proteger CloudFront."
  type        = bool
  default     = true
}

variable "enable_ip_block_rule" {
  description = "Habilita una regla WAF para bloquear manualmente IPs definidas en blocked_ip_addresses."
  type        = bool
  default     = true
}

variable "enable_rate_limit_rule" {
  description = "Habilita una regla WAF de límite de peticiones por IP."
  type        = bool
  default     = true
}

variable "rate_limit_requests" {
  description = "Cantidad máxima de peticiones permitidas por IP durante la ventana de evaluación."
  type        = number
  default     = 20

  validation {
    condition     = var.rate_limit_requests >= 10
    error_message = "rate_limit_requests debe ser mayor o igual a 10."
  }
}

variable "rate_limit_evaluation_window_sec" {
  description = "Ventana de evaluación del rate limit en segundos."
  type        = number
  default     = 60

  validation {
    condition     = contains([60, 120, 300, 600], var.rate_limit_evaluation_window_sec)
    error_message = "rate_limit_evaluation_window_sec debe ser 60, 120, 300 o 600."
  }
}

variable "kms_deletion_window_in_days" {
  description = "Días de espera antes de eliminar la llave KMS."
  type        = number
  default     = 10

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days debe estar entre 7 y 30."
  }
}

variable "enable_kms_key_rotation" {
  description = "Habilita la rotación automática de la llave KMS."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionales para los recursos del módulo."
  type        = map(string)
  default     = {}
}