  resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "ecs_api" {
  name        = "${local.name_prefix}-api-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # ECS Fargate usa el tipo 'ip'

  health_check {
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-tg"
  })
}


locals {
  # Determinamos el ARN del certificado correcto a usar basado en la region.
  # Si var.domain_name esta vacio, esto resultara en null.
  alb_cert_arn = var.domain_name != "" ? (
    var.aws_region == "us-east-1" ? aws_acm_certificate.cloudfront[0].arn : aws_acm_certificate.alb[0].arn
  ) : null
}


resource "aws_lb_listener" "https" {
  count = local.alb_cert_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = local.alb_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_api.arn
  }
}
