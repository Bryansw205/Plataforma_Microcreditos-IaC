resource "aws_ssm_parameter" "tasa_interes" {
  name        = "/${local.name_prefix}/app/tasa_interes"
  description = "Tasa de interés para ${local.name_prefix}"
  type        = "String"
  value       = "15.5"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-parameter-tasa"
  })
}

resource "aws_ssm_parameter" "limite_creditos" {
  name        = "/${local.name_prefix}/app/limite_creditos"
  description = "Limite de creditos para ${local.name_prefix}"
  type        = "String"
  value       = "5000"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-parameter-limite"
  })
}

resource "aws_ssm_parameter" "plazo_maximo" {
  name        = "/${local.name_prefix}/app/plazo_maximo"
  description = "Plazo máximo para ${local.name_prefix}"
  type        = "String"
  value       = "12"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-parameter-plazo"
  })
}

resource "aws_secretsmanager_secret" "db_api_credenciales" {
  name        = "${local.name_prefix}/app-credentials"
  description = "Credenciales para Aurora y APIs externas de ${local.name_prefix}"
  kms_key_id  = aws_kms_key.main.arn

  recovery_window_in_days = 30

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sm-secret"
  })
}

resource "aws_secretsmanager_secret_version" "db_api_credentials_value" {
  secret_id = aws_secretsmanager_secret.db_api_credenciales.id
  secret_string = jsonencode({
    username = "admin_microcreditos" #DB
    password = "cambiar_manualmente" #DB
    api_key_flow = "cambiar_manualmente"
    api_key_infocorp = "cambiar_manualmente"
  })
}
