locals {
  # Ruta base para parámetros SSM
  ssm_base_path = "/${local.name_prefix}"

  ssm_parameters = {
    "api/flow-api-url" = {
      type        = "SecureString"
      value       = var.flow_api_url
      description = "URL base de la API de Flow (gateway de pagos)"
      tier        = "Standard"
    }

    "api/infocorp-api-url" = {
      type        = "SecureString"
      value       = var.infocorp_api_url
      description = "URL base de la API de Infocorp (buró de crédito)"
      tier        = "Standard"
    }

    "creditos/monto-maximo" = {
      type        = "SecureString"
      value       = tostring(var.max_credit_amount)
      description = "Monto máximo de crédito permitido (en moneda local)"
      tier        = "Standard"
    }

    "creditos/monto-minimo" = {
      type        = "SecureString"
      value       = tostring(var.min_credit_amount)
      description = "Monto mínimo de crédito permitido (en moneda local)"
      tier        = "Standard"
    }

    "creditos/tasas-interes" = {
      type        = "SecureString"
      value       = jsonencode(var.interest_rates)
      description = "Tasas de interés por plazo de crédito (JSON)"
      tier        = "Standard"
    }

    "negocio/reglas-evaluacion" = {
      type        = "SecureString"
      value       = jsonencode(var.business_rules)
      description = "Reglas de negocio para evaluación de crédito (JSON)"
      tier        = "Standard"
    }

    "simulaciones/parametros" = {
      type        = "SecureString"
      value       = jsonencode(var.simulation_params)
      description = "Parámetros de simulación de créditos (JSON)"
      tier        = "Standard"
    }

    "logging/nivel-log" = {
      type        = "SecureString"
      value       = var.log_level
      description = "Nivel de logging (DEBUG, INFO, WARN, ERROR)"
      tier        = "Standard"
    }

    "logging/retention-dias" = {
      type        = "SecureString"
      value       = tostring(var.log_retention_days)
      description = "Días de retención de logs en CloudWatch"
      tier        = "Standard"
    }

    "features/modo-mantenimiento" = {
      type        = "SecureString"
      value       = "false"
      description = "Bandera para habilitar modo de mantenimiento"
      tier        = "Standard"
    }

    "features/verificacion-biometrica" = {
      type        = "SecureString"
      value       = var.environment == "prod" ? "true" : "false"
      description = "Habilitar verificación biométrica en producción"
      tier        = "Standard"
    }
  }
}

resource "aws_ssm_parameter" "config" {
  for_each = local.ssm_parameters

  name            = "${local.ssm_base_path}/${each.key}"
  type            = "SecureString"
  value           = each.value.value
  description     = each.value.description
  tier            = each.value.tier
  data_type       = "text"
  overwrite       = true
  allowed_pattern = null
  key_id          = var.secrets_kms_key_arn != null ? var.secrets_kms_key_arn : null
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}/${each.key}"
  })

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
    ]
  }
}

data "aws_iam_policy_document" "ssm_read_access" {
  statement {
    sid    = "ReadSSMParameters"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = [
      "arn:aws:ssm:*:*:parameter${local.ssm_base_path}/*"
    ]
  }

  statement {
    sid    = "DecryptParameters"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["ssm.*.amazonaws.com"]
    }
  }
}