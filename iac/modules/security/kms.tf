data "aws_caller_identity" "current" {}

resource "aws_kms_key" "main" {
  description             = "KMS key for ${local.name_prefix} security layer"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.enable_kms_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-security-kms-key"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}-security-kms"
  target_key_id = aws_kms_key.main.key_id
}