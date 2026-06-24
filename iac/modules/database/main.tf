
# RDS PostgreSQL

# Grupo de subredes que le dice a RDS en qué zonas privadas de la VPC puede vivir
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_data_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

# Parámetros del motor de la base de datos para asegurar rendimiento óptimo
resource "aws_db_parameter_group" "main" {
  name   = "${var.name_prefix}-postgres16-params"
  family = "postgres16"

  # Forzar conexiones TLS/SSL seguras para cumplir con la protección de datos en tránsito (RNF 16)
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "password_encryption"
    value = "scram-sha-256" # Cifrado robusto para los accesos internos
  }
}

# Instancia de Base de Datos Relacional PostgreSQL
resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-database"

  # Especificación del Motor solicitado
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = var.db_instance_class

  # Almacenamiento elástico e inteligente GP3
  allocated_storage     = 20
  max_allocated_storage = 100 # Permite auto-escalar si se llena el disco
  storage_type          = "gp3"

  # Cifrado de Datos Sensibles
  storage_encrypted = true
  kms_key_id        = var.rds_kms_key_arn # Llave criptográfica administrada

  # Credenciales del negocio (Se administrarán automáticamente a través de Secrets Manager)
  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true # Delega la contraseña a AWS de forma segura

  # Arquitectura Multi-AZ
  # Se activa automáticamente si el entorno es producción ("prod")
  multi_az = var.environment == "prod" ? true : false

  # Redes y Conectividad Segura
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  port                   = 5432

  # Ventanas de Mantenimiento y Respaldos Automatizados (Soporte de Recuperación)
  backup_retention_period = 7
  backup_window           = "03:00-04:00" # Se ejecuta en la madrugada de Perú
  maintenance_window      = "Mon:04:00-Mon:04:30"

  # Protección contra eliminaciones accidentales en producción
  deletion_protection = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment == "dev" ? true : false

  tags = {
    Name = "${var.name_prefix}-database"
    Tier = "Data"
  }
}