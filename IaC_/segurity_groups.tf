# ============================================================
# Security Groups - Plataforma de Microcréditos
# ============================================================

# CloudFront -> ALB
# AWS mantiene un prefix list administrado para permitir solo trafico
# origin-facing desde CloudFront hacia el Application Load Balancer.
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# ============================================================
# ALB Security Group
# Recibe trafico HTTPS desde CloudFront.
# ============================================================

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Permite trafico HTTPS desde CloudFront hacia el ALB"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_cloudfront" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS desde CloudFront hacia ALB"

  prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id
  from_port      = 443
  to_port        = 443
  ip_protocol    = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_api" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Trafico del ALB hacia ECS API"
  referenced_security_group_id = aws_security_group.ecs_api.id

  from_port   = var.backend_port
  to_port     = var.backend_port
  ip_protocol = "tcp"
}

# ============================================================
# ECS API Security Group
# Recibe trafico solo desde el ALB.
# ============================================================

resource "aws_security_group" "ecs_api" {
  name        = "${local.name_prefix}-ecs-api-sg"
  description = "Security Group para ECS API Service"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-api-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ecs_api_from_alb" {
  security_group_id            = aws_security_group.ecs_api.id
  description                  = "Permite trafico desde ALB hacia ECS API"
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.backend_port
  to_port     = var.backend_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_api_to_aurora" {
  security_group_id            = aws_security_group.ecs_api.id
  description                  = "ECS API hacia Aurora PostgreSQL"
  referenced_security_group_id = aws_security_group.aurora.id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_api_to_redis" {
  security_group_id            = aws_security_group.ecs_api.id
  description                  = "ECS API hacia Redis"
  referenced_security_group_id = aws_security_group.redis.id

  from_port   = var.redis_port
  to_port     = var.redis_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_api_to_https" {
  security_group_id = aws_security_group.ecs_api.id
  description       = "ECS API hacia servicios AWS y APIs externas por HTTPS"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# ============================================================
# ECS Worker Security Group
# No recibe trafico del ALB.
# Consume SQS y procesa tareas asincronas.
# ============================================================

resource "aws_security_group" "ecs_worker" {
  name        = "${local.name_prefix}-ecs-worker-sg"
  description = "Security Group para ECS Worker Service"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-worker-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "ecs_worker_to_aurora" {
  security_group_id            = aws_security_group.ecs_worker.id
  description                  = "ECS Worker hacia Aurora PostgreSQL"
  referenced_security_group_id = aws_security_group.aurora.id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_worker_to_redis" {
  security_group_id            = aws_security_group.ecs_worker.id
  description                  = "ECS Worker hacia Redis"
  referenced_security_group_id = aws_security_group.redis.id

  from_port   = var.redis_port
  to_port     = var.redis_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_worker_to_https" {
  security_group_id = aws_security_group.ecs_worker.id
  description       = "ECS Worker hacia SQS, S3, Secrets Manager, Parameter Store y APIs externas"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# ============================================================
# Aurora Security Group
# Aurora solo acepta trafico desde ECS API y ECS Worker.
# ============================================================

resource "aws_security_group" "aurora" {
  name        = "${local.name_prefix}-aurora-sg"
  description = "Security Group para Aurora PostgreSQL"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_ecs_api" {
  security_group_id            = aws_security_group.aurora.id
  description                  = "Conexion desde ECS API hacia Aurora"
  referenced_security_group_id = aws_security_group.ecs_api.id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_ecs_worker" {
  security_group_id            = aws_security_group.aurora.id
  description                  = "Conexion desde ECS Worker hacia Aurora"
  referenced_security_group_id = aws_security_group.ecs_worker.id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

# ============================================================
# Redis Security Group
# Redis solo acepta trafico desde ECS API y ECS Worker.
# ============================================================

resource "aws_security_group" "redis" {
  name        = "${local.name_prefix}-redis-sg"
  description = "Security Group para ElastiCache Redis"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_ecs_api" {
  security_group_id            = aws_security_group.redis.id
  description                  = "Conexion desde ECS API hacia Redis"
  referenced_security_group_id = aws_security_group.ecs_api.id

  from_port   = var.redis_port
  to_port     = var.redis_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_ecs_worker" {
  security_group_id            = aws_security_group.redis.id
  description                  = "Conexion desde ECS Worker hacia Redis"
  referenced_security_group_id = aws_security_group.ecs_worker.id

  from_port   = var.redis_port
  to_port     = var.redis_port
  ip_protocol = "tcp"
}