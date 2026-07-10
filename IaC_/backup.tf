# ============================================================
# AWS Backup - Planes de Respaldo Aurora PostgreSQL
# ============================================================

resource "aws_backup_vault" "main" {
  name        = "${local.name_prefix}-backup-vault"
  kms_key_arn = aws_kms_key.main.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-vault"
  })
}

resource "aws_backup_plan" "main" {
  name = "${local.name_prefix}-backup-plan"

  rule {
    rule_name         = "daily_backup_rule"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)" # Todos los días a las 05:00 UTC

    lifecycle {
      delete_after = 30 # Retener por 30 días
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-plan"
  })
}

resource "aws_iam_role" "backup" {
  name = "${local.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-role"
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

resource "aws_iam_role_policy_attachment" "backup_restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup.name
}

resource "aws_backup_selection" "aurora" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${local.name_prefix}-aurora-backup-selection"
  plan_id      = aws_backup_plan.main.id

  resources = [
    aws_rds_cluster.aurora.arn
  ]
}
