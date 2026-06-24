variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos (ej: microcreditos-dev)"
  type        = string
}

variable "environment" {
  description = "Entorno actual de trabajo (dev, staging, prod)"
  type        = string
}

variable "private_data_subnet_ids" {
  description = "Mapeo temporal: Aqui se recibiran los IDs de subredes de Mayli"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Mapeo temporal: Aqui se recibira el firewall de Angel"
  type        = string
}

variable "rds_kms_key_arn" {
  description = "ARN de la llave KMS para el cifrado en reposo (RNF 14)"
  type        = string
}

variable "db_instance_class" {
  description = "Clase de la instancia solicitado para la base de datos"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Nombre inicial de la base de datos transaccional"
  type        = string
  default     = "microcreditos"
}

variable "db_username" {
  description = "Usuario maestro administrador de la base de datos"
  type        = string
  default     = "dbadmin"
}