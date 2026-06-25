# ============================================================
# Plataforma de Microcréditos – Orquestador de Infraestructura
# ============================================================
# Orden de despliegue por capas de dependencia:
#   1. Networking    – VPC, subredes, NAT, rutas
#   2. Security      – SGs, KMS, WAF
#   3. Observability – CloudWatch, SNS, X-Ray
#   4. Database      – RDS PostgreSQL
#   5. Storage       – S3 buckets (documentos)
#   6. Cache         – ElastiCache Redis
#   7. Auth          – Cognito User Pool
#   8. Config        – SSM Parameters, Secrets Manager
#   9. Messaging     – SQS colas + DLQ
#  10. CDN           – CloudFront
#  11. Backup        – AWS Backup (RDS + S3)
# ============================================================

# ─────────────────────────────────────────────────────────────
# Recursos para VPC Flow Logs (requeridos por el módulo networking)
# ─────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${local.name_prefix}/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.security.kms_key_arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-flow-logs"
  })
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${local.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${local.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

# ─────────────────────────────────────────────────────────────
# Capa 1 – Networking
# ─────────────────────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project_name     = var.project_name
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  availability_zones        = var.availability_zones
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
  enable_ha_nat    = var.enable_ha_nat

  flow_log_role_arn  = aws_iam_role.vpc_flow_logs.arn
  flow_log_group_arn = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

# ─────────────────────────────────────────────────────────────
# Capa 2 – Security (SGs, KMS, WAF)
# ─────────────────────────────────────────────────────────────

module "security" {
  source = "./modules/security"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id

  backend_port  = var.backend_port
  database_port = var.database_port
  redis_port    = var.redis_port

  allowed_http_cidr_blocks  = var.allowed_http_cidr_blocks
  allowed_https_cidr_blocks = var.allowed_https_cidr_blocks

  # WAF
  enable_regional_waf   = var.enable_regional_waf
  enable_cloudfront_waf = var.enable_cloudfront_waf
  blocked_ip_addresses  = var.blocked_ip_addresses

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# Capa 3 – Observability (CloudWatch, SNS, X-Ray)
# ─────────────────────────────────────────────────────────────

module "observability" {
  source = "./modules/observability"

  project     = var.project_name
  environment = var.environment

  notification_email      = var.notification_email
  ecs_cluster_name        = var.ecs_cluster_name
  ecs_service_name        = var.ecs_service_name
  alb_arn_suffix          = var.alb_arn_suffix
  target_group_arn_suffix = var.target_group_arn_suffix
  log_retention_days      = var.log_retention_days
  kms_key_arn             = module.security.kms_key_arn
}

# ─────────────────────────────────────────────────────────────
# Capa 4 – Database (RDS PostgreSQL)
# ─────────────────────────────────────────────────────────────

module "database" {
  source = "./modules/database"

  name_prefix            = local.name_prefix
  environment            = var.environment
  private_data_subnet_ids = module.networking.private_data_subnet_ids
  rds_security_group_id  = module.security.database_security_group_id
  rds_kms_key_arn        = module.security.kms_key_arn

  db_instance_class = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
}

# ─────────────────────────────────────────────────────────────
# Capa 5 – Storage (S3 Buckets)
# ─────────────────────────────────────────────────────────────

module "storage" {
  source = "./modules/storage"

  name_prefix    = local.name_prefix
  environment    = var.environment
  s3_kms_key_arn = module.security.kms_key_arn
}

# ─────────────────────────────────────────────────────────────
# Capa 6 – Cache (ElastiCache Redis)
# ─────────────────────────────────────────────────────────────

module "cache" {
  source = "./modules/cache"

  name_prefix                   = local.name_prefix
  environment                   = var.environment
  private_data_subnet_ids       = module.networking.private_data_subnet_ids
  elasticache_security_group_id = module.security.redis_security_group_id
  elasticache_kms_key_arn       = module.security.kms_key_arn

  cache_node_type = var.cache_node_type
}

# ─────────────────────────────────────────────────────────────
# Capa 7 – Auth (Cognito)
# ─────────────────────────────────────────────────────────────

module "auth" {
  source = "./modules/auth"

  providers = {
    aws            = aws
    aws.us-east-1  = aws.us-east-1
  }

  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name

  kms_key_id                 = module.security.kms_key_arn
  enable_deletion_protection = var.enable_deletion_protection

  password_minimum_length          = var.password_minimum_length
  password_require_symbols         = var.password_require_symbols
  temporary_password_validity_days = var.temporary_password_validity_days

  access_token_validity_minutes = var.access_token_validity_minutes
  refresh_token_validity_hours  = var.refresh_token_validity_hours

  custom_attributes = var.cognito_custom_attributes

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# Capa 8 – Config (SSM Parameters + Secrets Manager)
# ─────────────────────────────────────────────────────────────

module "config" {
  source = "./modules/config"

  providers = {
    aws            = aws
    aws.us-east-1  = aws.us-east-1
  }

  project_name       = var.project_name
  environment        = var.environment
  secrets_kms_key_arn = module.security.kms_key_arn

  flow_api_url    = var.flow_api_url
  infocorp_api_url = var.infocorp_api_url

  max_credit_amount = var.max_credit_amount
  min_credit_amount = var.min_credit_amount
  interest_rates    = var.interest_rates
  business_rules    = var.business_rules
  simulation_params = var.simulation_params

  jwt_expiry_hours       = var.jwt_expiry_hours
  jwt_refresh_expiry_days = var.jwt_refresh_expiry_days

  log_level          = var.log_level
  log_retention_days = var.log_retention_days

  create_database_secret = var.create_database_secret
  database_name          = var.db_name

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# Capa 9 – Messaging (SQS + DLQ)
# ─────────────────────────────────────────────────────────────

module "messaging" {
  source = "./modules/messaging"

  name_prefix    = local.name_prefix
  environment    = var.environment
  sqs_kms_key_arn = module.security.kms_key_arn

  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  max_receive_count          = var.sqs_max_receive_count
  dlq_retention_seconds      = var.sqs_dlq_retention_seconds
}

# ─────────────────────────────────────────────────────────────
# Capa 10 – CDN (CloudFront)
# ─────────────────────────────────────────────────────────────

module "cdn" {
  source = "./modules/cdn"

  project     = var.project_name
  environment = var.environment

  frontend_bucket_name                 = var.frontend_bucket_name
  frontend_bucket_regional_domain_name = var.frontend_bucket_regional_domain_name

  acm_certificate_arn = var.acm_certificate_arn
  domain_aliases      = var.cdn_domain_aliases
  web_acl_id          = module.security.cloudfront_waf_web_acl_arn
  price_class         = var.cdn_price_class
}

# ─────────────────────────────────────────────────────────────
# Capa 11 – Backup (AWS Backup para RDS + S3)
# ─────────────────────────────────────────────────────────────

module "backup" {
  source = "./modules/backup"

  name_prefix    = local.name_prefix
  environment    = var.environment

  rds_instance_arn   = module.database.db_instance_arn
  s3_bucket_arn      = module.storage.documents_bucket_arn
  backup_kms_key_arn = module.security.kms_key_arn

  backup_schedule        = var.backup_schedule
  backup_retention_days  = var.backup_retention_days
  backup_window_minutes  = var.backup_window_minutes
}
