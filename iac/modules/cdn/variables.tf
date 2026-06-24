variable "project" {
  type        = string
  description = "Nombre del proyecto."
}

variable "environment" {
  type        = string
  description = "Ambiente de despliegue: dev, test o prod."
}

variable "frontend_bucket_name" {
  type        = string
  description = "Nombre del bucket S3 que almacena el frontend estático."
}

variable "frontend_bucket_regional_domain_name" {
  type        = string
  description = "Dominio regional del bucket S3 usado como origen de CloudFront."
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN del certificado ACM para HTTPS en CloudFront."
  default     = null
}

variable "domain_aliases" {
  type        = list(string)
  description = "Dominios personalizados asociados a CloudFront."
  default     = []
}

variable "web_acl_id" {
  type        = string
  description = "ID o ARN del Web ACL de AWS WAF asociado a CloudFront."
  default     = null
}

variable "price_class" {
  type        = string
  description = "Clase de precio de CloudFront."
  default     = "PriceClass_100"
}