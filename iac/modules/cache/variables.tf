variable "name_prefix" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "environment" {
  description = "Entorno actual de trabajo (dev, staging, prod)"
  type        = string
}

variable "private_data_subnet_ids" {
  description = "Lista de subredes privadas donde se desplegará el cluster de cache"
  type        = list(string)
}

variable "elasticache_security_group_id" {
  description = "ID del grupo de seguridad para ElastiCache Redis"
  type        = string
}

variable "cache_node_type" {
  description = "Tipo de instancia solicitado para los nodos de cache"
  type        = string
  default     = "cache.t4g.micro" # Configurado exactamente como lo solicitaste
}