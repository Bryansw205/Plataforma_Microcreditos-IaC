# ============================================================
# AWS Certificate Manager (ACM) - SSL/TLS
# ============================================================

variable "domain_name" {
  description = "Nombre del dominio principal para la aplicacion (opcional, ej: microcreditos.com)"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Nombres alternativos de dominio (Subject Alternative Names - SAN)"
  type        = list(string)
  default     = []
}

# 1. Certificado para CloudFront (Siempre requerido en la region us-east-1)
resource "aws_acm_certificate" "cloudfront" {
  count             = var.domain_name != "" ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Certificado para el ALB (Requerido en la region del despliegue principal)
# Si la region principal es diferente de us-east-1, se crea este certificado.
resource "aws_acm_certificate" "alb" {
  count             = var.domain_name != "" && var.aws_region != "us-east-1" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}
