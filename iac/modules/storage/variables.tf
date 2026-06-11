variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "environment" {
  description = "Entorno actual de trabajo (dev, staging, prod)"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "ARN de la llave KMS para el cifrado seguro de documentos en reposo"
  type        = string
}