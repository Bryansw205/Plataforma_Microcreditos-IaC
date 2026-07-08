resource "aws_kms_key" "main" {
  description             = "KMS key para ${local.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-kms-key"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}-kms"
  target_key_id = aws_kms_key.main.key_id
}
