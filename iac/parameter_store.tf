resource "aws_ssm_parameter" "environment_config" {
  name        = "/${local.name_prefix}/environment/config"
  description = "Configuración general del entorno ${var.environment}"

  type   = "SecureString"
  key_id = module.security.kms_key_arn

  value = jsonencode({
    environment = var.environment
    region      = var.aws_region
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-environment-config"
  })
}
