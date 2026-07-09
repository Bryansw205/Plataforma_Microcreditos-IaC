resource "aws_secretsmanager_secret" "db_api_credenciales" {
  #checkov:skip=CKV2_AWS_57: La rotacion automatica se configurara en entornos de produccion segun necesidades de seguridad.
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
