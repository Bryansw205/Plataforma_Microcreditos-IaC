
# Amazon ElastiCache Redis

# Grupo de subredes exclusivo para los nodos de cache en memoria
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis-subnet-group"
  subnet_ids = var.private_data_subnet_ids
}

# Grupo de parámetros para configurar la lógica de limpieza de memoria RAM
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.name_prefix}-redis7-params"
  family = "redis7"

  # Estrategia de desalojo: Si la RAM se llena, borra los datos menos usados recientemente (LRU)
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

# Generar un token aleatorio de autenticación para Redis
resource "random_password" "auth_token" {
  length  = 32
  special = false # Los tokens de Redis funcionan mejor con solo caracteres alfanuméricos
}

# Grupo de Replicación de Redis (Clúster)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.name_prefix}-redis"
  description          = "Capa de cache ultrarapida en memoria para evaluar creditos"

  # Arquitectura de Computo y Motor solicitado
  engine         = "redis"
  engine_version = "7.1"
  node_type      = var.cache_node_type
  port           = 6379

  # Configuración de Red y Seguridad Interna
  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.elasticache_security_group_id]

  # Seguridad de los Datos (Cifrado en tránsito obligatorio de AWS Redis)
  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                 = var.elasticache_kms_key_arn
  auth_token                 = random_password.auth_token.result

  # Táctica de disponibilidad: Habilita nodos de respaldo automáticos y failover siempre en true (CKV2_AWS_50)
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  tags = {
    Name = "${var.name_prefix}-redis-cache"
  }
}