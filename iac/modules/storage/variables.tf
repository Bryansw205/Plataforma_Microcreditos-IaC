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

variable "log_bucket_domain_name" {
  description = "Domain of the log bucket"
  type        = string
  default     = ""
}

variable "replication_iam_role_arn" {
  description = "ARN of the replication IAM role"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for bucket notifications"
  type        = string
  default     = ""
}