resource "aws_ssm_parameter" "tasa_interes" {
  name        = "/${local.name_prefix}/app/tasa_interes"
  description = "Tasa de interés para ${local.name_prefix}"
  type        = "SecureString"
  key_id      = aws_kms_key.main.arn
  value       = "15.5"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-parameter-tasa"
  })
}

resource "aws_ssm_parameter" "limite_creditos" {
  name        = "/${local.name_prefix}/app/limite_creditos"
  description = "Limite de creditos para ${local.name_prefix}"
  type        = "SecureString"
  key_id      = aws_kms_key.main.arn
  value       = "5000"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-parameter-limite"
  })
}

resource "aws_ssm_parameter" "plazo_maximo" {
  name        = "/${local.name_prefix}/app/plazo_maximo"
  description = "Plazo máximo para ${local.name_prefix}"
  type        = "SecureString"
  key_id      = aws_kms_key.main.arn
  value       = "12"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-parameter-plazo"
  })
}
