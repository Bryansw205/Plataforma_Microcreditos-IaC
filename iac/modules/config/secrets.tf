resource "aws_secretsmanager_secret" "api_keys" {
  # checkov:skip=CKV2_AWS_57: Las claves de proveedores externos se gestionan en sus respectivos portales; AWS no tiene control para rotarlas automáticamente.
  name_prefix             = "${local.name_prefix}-api-keys-"
  description             = "Claves de API para servicios externos (Flow, Infocorp)"
  kms_key_id              = var.secrets_kms_key_arn != null ? var.secrets_kms_key_arn : null
  recovery_window_in_days = var.environment == "prod" ? 30 : 7
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-keys"
  })
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id

  secret_string = jsonencode({
    flow_api_key     = var.environment == "prod" ? "Cambiar_luego" : "desarrollo-key",
    flow_api_secret  = var.environment == "prod" ? "Cambiar_luego" : "desarrollo-secret",
    infocorp_api_key = var.environment == "prod" ? "Cambiar_luego" : "desarrollo-key",
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "jwt_config" {
  # checkov:skip=CKV2_AWS_57: La rotación dinámica del secreto JWT sin manejo de estado invalidaría abruptamente las sesiones activas de los usuarios.
  name_prefix             = "${local.name_prefix}-jwt-config-"
  description             = "Configuración de JWT: clave privada, algoritmo, expiración"
  kms_key_id              = var.secrets_kms_key_arn != null ? var.secrets_kms_key_arn : null
  recovery_window_in_days = var.environment == "prod" ? 30 : 7
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-jwt-config"
  })
}

resource "aws_secretsmanager_secret_version" "jwt_config" {
  secret_id = aws_secretsmanager_secret.jwt_config.id

  secret_string = jsonencode({
    algorithm         = "HS256"
    jwt_secret        = var.environment == "prod" ? "GENERAR_CLAVE_SEGURA" : "desarrollo-secret-key-128-bits",
    jwt_expiry_hours  = var.jwt_expiry_hours
    refresh_expiry_days = var.jwt_refresh_expiry_days
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "database" {
  # checkov:skip=CKV2_AWS_57: La rotación automatizada interrumpiría las conexiones persistentes de los contenedores; se asume como procedimiento operativo administrado.
  count                   = var.create_database_secret ? 1 : 0
  name_prefix             = "${local.name_prefix}-database-"
  description             = "Credenciales de base de datos RDS"
  kms_key_id              = var.secrets_kms_key_arn != null ? var.secrets_kms_key_arn : null
  recovery_window_in_days = var.environment == "prod" ? 30 : 7
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database"
  })
}

resource "aws_secretsmanager_secret_version" "database" {
  count     = var.create_database_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.database[0].id

  secret_string = jsonencode({
    username = "root"
    password = "db123"
    engine   = "postgres"
    host     = "localhost"
    port     = 5432
    dbname   = var.database_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "aws_iam_policy_document" "secrets_read_access" {
  statement {
    sid    = "ReadSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = [
      aws_secretsmanager_secret.api_keys.arn,
      aws_secretsmanager_secret.jwt_config.arn,
    ]
  }

  dynamic "statement" {
    for_each = var.create_database_secret ? [1] : []
    content {
      sid    = "ReadDatabaseSecret"
      effect = "Allow"

      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
      ]

      resources = [
        aws_secretsmanager_secret.database[0].arn,
      ]
    }
  }

  statement {
    sid    = "DecryptSecrets"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["secretsmanager.*.amazonaws.com"]
    }
  }
}