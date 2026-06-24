# ============================================================
# Variables Raíz – Plataforma de Microcréditos
# ============================================================

# ─────────────────────────────────────────────────────────────
# Generales
# ─────────────────────────────────────────────────────────────

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

# ─────────────────────────────────────────────────────────────
# Networking
# ─────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidad para desplegar subredes."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Bloques CIDR para subredes públicas (una por AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Bloques CIDR para subredes privadas de aplicación (una por AZ)."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_data_subnet_cidrs" {
  description = "Bloques CIDR para subredes privadas de datos (una por AZ)."
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "enable_ha_nat" {
  description = "Habilita NAT Gateway por cada AZ para alta disponibilidad. Desactivar en dev para reducir costos."
  type        = bool
  default     = false
}

# ─────────────────────────────────────────────────────────────
# Security
# ─────────────────────────────────────────────────────────────

variable "backend_port" {
  description = "Puerto donde escuchará el backend en ECS/Fargate."
  type        = number
  default     = 8080
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

variable "enable_regional_waf" {
  description = "Habilita AWS WAF regional para proteger el ALB."
  type        = bool
  default     = true
}

variable "enable_cloudfront_waf" {
  description = "Habilita AWS WAF global para proteger CloudFront."
  type        = bool
  default     = true
}

variable "blocked_ip_addresses" {
  description = "Lista de IPs o rangos CIDR que serán bloqueados por AWS WAF."
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────────────────────
# Observability
# ─────────────────────────────────────────────────────────────

variable "notification_email" {
  description = "Correo del equipo de soporte para recibir alertas SNS."
  type        = string
  default     = "angelfrancasanovach@gmail.com"
}

variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS a monitorear (se configura cuando el módulo de compute exista)."
  type        = string
  default     = "placeholder-cluster"
}

variable "ecs_service_name" {
  description = "Nombre del servicio ECS a monitorear (se configura cuando el módulo de compute exista)."
  type        = string
  default     = "placeholder-service"
}

variable "alb_arn_suffix" {
  description = "ARN suffix del Application Load Balancer para métricas CloudWatch."
  type        = string
  default     = "placeholder-alb-suffix"
}

variable "target_group_arn_suffix" {
  description = "ARN suffix del Target Group del ALB para métricas CloudWatch."
  type        = string
  default     = "placeholder-tg-suffix"
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch."
  type        = number
  default     = 30
}

# ─────────────────────────────────────────────────────────────
# Database (RDS PostgreSQL)
# ─────────────────────────────────────────────────────────────

variable "db_instance_class" {
  description = "Clase de la instancia para la base de datos."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Nombre inicial de la base de datos transaccional."
  type        = string
  default     = "microcreditos"
}

variable "db_username" {
  description = "Usuario maestro administrador de la base de datos."
  type        = string
  default     = "dbadmin"
}

# ─────────────────────────────────────────────────────────────
# Cache (ElastiCache Redis)
# ─────────────────────────────────────────────────────────────

variable "cache_node_type" {
  description = "Tipo de instancia para los nodos de cache Redis."
  type        = string
  default     = "cache.t4g.micro"
}

# ─────────────────────────────────────────────────────────────
# Auth (Cognito)
# ─────────────────────────────────────────────────────────────

variable "domain_name" {
  description = "Nombre de dominio principal para la aplicación (ej: microcreditos.example.com)."
  type        = string
  default     = "deciradios.com"
}

variable "enable_deletion_protection" {
  description = "Habilitar protección de eliminación para el Pool de Usuarios Cognito (recomendado para prod)."
  type        = bool
  default     = true
}

variable "password_minimum_length" {
  description = "Longitud mínima de contraseña para Cognito (8-128 caracteres)."
  type        = number
  default     = 12
}

variable "password_require_symbols" {
  description = "Requerir caracteres especiales en contraseñas de Cognito."
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Días de validez para contraseñas temporales de Cognito (1-365 días)."
  type        = number
  default     = 7
}

variable "access_token_validity_minutes" {
  description = "Validez del token de acceso de Cognito en minutos."
  type        = number
  default     = 15
}

variable "refresh_token_validity_hours" {
  description = "Validez del token de refresco de Cognito en horas."
  type        = number
  default     = 24
}

variable "cognito_custom_attributes" {
  description = "Atributos personalizados adicionales para el pool de usuarios de Cognito."
  type = list(object({
    name     = string
    type     = string
    required = bool
    mutable  = bool
  }))
  default = []
}

# ─────────────────────────────────────────────────────────────
# Config (SSM + Secrets Manager)
# ─────────────────────────────────────────────────────────────

variable "flow_api_url" {
  description = "URL base de la API de Flow (gateway de pagos)."
  type        = string
  default     = "https://api.flow.cl/v1"
}

variable "infocorp_api_url" {
  description = "URL base de la API de Infocorp (buró de crédito)."
  type        = string
  default     = "https://api.infocorp.com.pe/v1"
}

variable "max_credit_amount" {
  description = "Monto máximo de crédito permitido (en moneda local)."
  type        = number
  default     = 50000
}

variable "min_credit_amount" {
  description = "Monto mínimo de crédito permitido (en moneda local)."
  type        = number
  default     = 500
}

variable "interest_rates" {
  description = "Tasas de interés por plazo."
  type        = map(number)
  default = {
    "12_months" = 0.15
    "24_months" = 0.18
    "36_months" = 0.22
  }
}

variable "business_rules" {
  description = "Reglas de negocio para evaluación de créditos."
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
  description = "Parámetros para simulación de créditos."
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
  description = "Horas de expiración para tokens JWT de acceso."
  type        = number
  default     = 24
}

variable "jwt_refresh_expiry_days" {
  description = "Días de expiración para tokens JWT de refresco."
  type        = number
  default     = 30
}

variable "log_level" {
  description = "Nivel de logging: DEBUG, INFO, WARN, ERROR."
  type        = string
  default     = "INFO"
}

variable "create_database_secret" {
  description = "Crear secreto para credenciales de base de datos en Secrets Manager."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────────────────────
# Messaging (SQS)
# ─────────────────────────────────────────────────────────────

variable "sqs_visibility_timeout_seconds" {
  description = "Tiempo en segundos que un mensaje permanece invisible tras ser leído."
  type        = number
  default     = 30
}

variable "sqs_message_retention_seconds" {
  description = "Tiempo máximo de retención de mensajes en la cola principal (default: 4 días)."
  type        = number
  default     = 345600
}

variable "sqs_receive_wait_time_seconds" {
  description = "Tiempo de espera en long-polling para reducir llamadas vacías."
  type        = number
  default     = 10
}

variable "sqs_max_receive_count" {
  description = "Número máximo de reintentos antes de mover el mensaje a la DLQ."
  type        = number
  default     = 3
}

variable "sqs_dlq_retention_seconds" {
  description = "Tiempo de retención en la DLQ (default: 14 días)."
  type        = number
  default     = 1209600
}

# ─────────────────────────────────────────────────────────────
# CDN (CloudFront)
# ─────────────────────────────────────────────────────────────

variable "frontend_bucket_name" {
  description = "Nombre del bucket S3 que almacena el frontend estático."
  type        = string
  default     = "microcreditos-dev-frontend"
}

variable "frontend_bucket_regional_domain_name" {
  description = "Dominio regional del bucket S3 usado como origen de CloudFront."
  type        = string
  default     = "microcreditos-dev-frontend.s3.us-east-1.amazonaws.com"
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM para HTTPS en CloudFront."
  type        = string
  default     = null
}

variable "cdn_domain_aliases" {
  description = "Dominios personalizados asociados a CloudFront."
  type        = list(string)
  default     = []
}

variable "cdn_price_class" {
  description = "Clase de precio de CloudFront."
  type        = string
  default     = "PriceClass_100"
}

# ─────────────────────────────────────────────────────────────
# Backup (AWS Backup)
# ─────────────────────────────────────────────────────────────

variable "backup_schedule" {
  description = "Expresión cron de AWS para la frecuencia del respaldo (default: diario a las 3:00 AM UTC)."
  type        = string
  default     = "cron(0 3 * * ? *)"
}

variable "backup_retention_days" {
  description = "Número de días que se conservarán los puntos de recuperación."
  type        = number
  default     = 7
}

variable "backup_window_minutes" {
  description = "Duración máxima en minutos de la ventana de respaldo."
  type        = number
  default     = 120
}