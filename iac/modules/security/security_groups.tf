resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "backend" {
  name        = "${local.name_prefix}-backend-sg"
  description = "Security group for ECS Fargate backend"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-sg"
  })
}

resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-database-sg"
  description = "Security group for PostgreSQL or Aurora database"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-sg"
  })
}

resource "aws_security_group" "redis" {
  name        = "${local.name_prefix}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = toset(var.allowed_http_cidr_blocks)

  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic from allowed CIDR blocks"
  cidr_ipv4         = each.value
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = toset(var.allowed_https_cidr_blocks)

  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic from allowed CIDR blocks"
  cidr_ipv4         = each.value
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_backend" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Allow ALB to send traffic to backend"
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = var.backend_port
  ip_protocol                  = "tcp"
  to_port                      = var.backend_port
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_alb" {
  security_group_id            = aws_security_group.backend.id
  description                  = "Allow backend traffic only from ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.backend_port
  ip_protocol                  = "tcp"
  to_port                      = var.backend_port
}

resource "aws_vpc_security_group_egress_rule" "backend_to_database" {
  security_group_id            = aws_security_group.backend.id
  description                  = "Allow backend to connect to database"
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = var.database_port
  ip_protocol                  = "tcp"
  to_port                      = var.database_port
}

resource "aws_vpc_security_group_ingress_rule" "database_from_backend" {
  security_group_id            = aws_security_group.database.id
  description                  = "Allow database connections only from backend"
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = var.database_port
  ip_protocol                  = "tcp"
  to_port                      = var.database_port
}

resource "aws_vpc_security_group_egress_rule" "backend_to_redis" {
  security_group_id            = aws_security_group.backend.id
  description                  = "Allow backend to connect to Redis"
  referenced_security_group_id = aws_security_group.redis.id
  from_port                    = var.redis_port
  ip_protocol                  = "tcp"
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_backend" {
  security_group_id            = aws_security_group.redis.id
  description                  = "Allow Redis connections only from backend"
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = var.redis_port
  ip_protocol                  = "tcp"
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_egress_rule" "backend_to_https" {
  security_group_id = aws_security_group.backend.id
  description       = "Allow backend to access AWS services and external APIs over HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}