
# AWS Backup – Módulo de Respaldo Centralizado
# Protege la base de datos RDS PostgreSQL y el bucket S3 de documentos legales

# ═══════════════════════════════════════════════════════════
# 1. ROL IAM DEDICADO PARA EL SERVICIO DE AWS BACKUP
# ═══════════════════════════════════════════════════════════

# Política de confianza: permite que el servicio de AWS Backup asuma este rol
data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

# Rol de servicio exclusivo para las operaciones de respaldo y restauración
resource "aws_iam_role" "backup" {
  name               = "${var.name_prefix}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json

  tags = {
    Name = "${var.name_prefix}-backup-role"
  }
}

# Política administrada por AWS: permisos para CREAR respaldos (snapshots, copias)
resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Política administrada por AWS: permisos para RESTAURAR respaldos
resource "aws_iam_role_policy_attachment" "restore_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Política adicional para respaldo de S3 (requerida por AWS Backup para buckets)
resource "aws_iam_role_policy_attachment" "s3_backup_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

# Política adicional para restauración de S3
resource "aws_iam_role_policy_attachment" "s3_restore_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
}

# ═══════════════════════════════════════════════════════════
# 2. BÓVEDA DE RESPALDOS (Backup Vault)
# ═══════════════════════════════════════════════════════════

# Contenedor seguro donde se almacenan todos los puntos de recuperación
resource "aws_backup_vault" "main" {
  name = "${var.name_prefix}-backup-vault"

  tags = {
    Name        = "${var.name_prefix}-backup-vault"
    Environment = var.environment
  }
}

# ═══════════════════════════════════════════════════════════
# 3. PLAN DE RESPALDO (Backup Plan)
# ═══════════════════════════════════════════════════════════

# Define la estrategia: CUÁNDO se respalda y CUÁNTO TIEMPO se retiene
resource "aws_backup_plan" "daily" {
  name = "${var.name_prefix}-daily-backup-plan"

  # Regla principal: Respaldo diario automático en horas de menor tráfico
  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.main.name

    # Frecuencia del respaldo según el SLA definido (por defecto: diario a las 3 AM UTC)
    schedule = var.backup_schedule

    # Ventana de inicio: AWS Backup tiene hasta N minutos para completar el respaldo
    start_window = var.backup_window_minutes

    # Ventana de completado: tiempo máximo antes de cancelar (8 horas)
    completion_window = 480

    # Retención: Cuántos días se conserva cada punto de recuperación
    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = {
    Name        = "${var.name_prefix}-daily-backup-plan"
    Environment = var.environment
  }
}

# ═══════════════════════════════════════════════════════════
# 4. SELECCIÓN DE RECURSOS A PROTEGER (Backup Selection)
# ═══════════════════════════════════════════════════════════

# Selección: Instancia RDS PostgreSQL (base de datos transaccional de microcréditos)
resource "aws_backup_selection" "rds" {
  name         = "${var.name_prefix}-rds-selection"
  plan_id      = aws_backup_plan.daily.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [var.rds_instance_arn]
}

# Selección: Bucket S3 de documentos y evidencias legales
resource "aws_backup_selection" "s3" {
  name         = "${var.name_prefix}-s3-selection"
  plan_id      = aws_backup_plan.daily.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [var.s3_bucket_arn]
}
