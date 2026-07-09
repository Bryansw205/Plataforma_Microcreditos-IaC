# ============================================================
# Aurora PostgreSQL - Plataforma de Microcréditos
# ============================================================

resource "aws_db_subnet_group" "aurora" {
  name        = "${local.name_prefix}-aurora-subnet-group"
  description = "Subnet group privado para Aurora PostgreSQL"

  subnet_ids = aws_subnet.private_data[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-subnet-group"
  })
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${local.name_prefix}-aurora-postgresql"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  engine         = "aurora-postgresql"
  engine_version = var.aurora_engine_version
  database_name  = var.aurora_database_name

  master_username             = var.aurora_master_username
  manage_master_user_password = true
  master_user_secret_kms_key_id = aws_kms_key.main.arn

  iam_database_authentication_enabled = true

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  port = var.database_port

  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn

  backup_retention_period      = var.aurora_backup_retention_period
  preferred_backup_window      = var.aurora_preferred_backup_window
  preferred_maintenance_window = var.aurora_preferred_maintenance_window

  copy_tags_to_snapshot = true
  deletion_protection   = var.aurora_deletion_protection
  skip_final_snapshot   = var.aurora_skip_final_snapshot

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-cluster"
    Type = "database"
  })
}

resource "aws_rds_cluster_instance" "aurora" {

  monitoring_interval = 15
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  count = var.aurora_instance_count

  identifier         = "${local.name_prefix}-aurora-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version

  instance_class = var.aurora_instance_class

  db_subnet_group_name = aws_db_subnet_group.aurora.name

  publicly_accessible = false

  auto_minor_version_upgrade = true
  apply_immediately          = var.aurora_apply_immediately

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.main.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-${count.index + 1}"
    Role = count.index == 0 ? "writer" : "reader"
  })
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${local.name_prefix}-aurora-params"
  family      = "aurora-postgresql15"
  description = "Parameter group para Aurora PostgreSQL con query logging (RNF_27)"

  parameter {
    name  = "log_statement"
    value = "ddl"   # Registra cambios de estructura (DDL). Usa "all" para máxima auditoría.
    apply_method = "immediate"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"   # Registra queries > 1 segundo (relevante para RNF_09)
    apply_method = "immediate"
  }

  parameter {
    name  = "log_connections"
    value = "1"
    apply_method = "immediate"
  }

  tags = local.common_tags
}

