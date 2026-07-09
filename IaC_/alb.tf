locals {
  alb_certificate_arn = var.domain_name != "" ? (
    var.aws_region == "us-east-1"
    ? aws_acm_certificate.cloudfront[0].arn
    : aws_acm_certificate.alb[0].arn
  ) : null
}

resource "aws_lb" "api" {
  name               = "${local.name_prefix}-api-alb"
  internal           = false
  load_balancer_type = "application"
  
  access_logs {
    bucket  = aws_s3_bucket.audit.bucket
    prefix  = "alb-access-logs"
    enabled = true
  }
  
  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  enable_deletion_protection = var.alb_enable_deletion_protection
  enable_http2               = true
  drop_invalid_header_fields = true
  idle_timeout               = var.alb_idle_timeout

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-alb"
    Type = "application-load-balancer"
  })
}

resource "aws_lb_target_group" "ecs_api" {
# checkov:skip=CKV_AWS_378:SSL termination en ALB. Tráfico ALB→ECS es HTTP interno en subnet privada (private_app). No expuesto externamente. :3
  name        = "${local.name_prefix}-ecs-api-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  deregistration_delay = var.alb_deregistration_delay

  health_check {
    enabled             = true
    path                = var.alb_health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = var.alb_health_check_interval
    timeout             = var.alb_health_check_timeout
    healthy_threshold   = var.alb_healthy_threshold
    unhealthy_threshold = var.alb_unhealthy_threshold
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-api-tg"
    Type = "ecs-api-target-group"
  })
}

resource "aws_lb_listener" "https" {
  count = local.alb_certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.api.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = local.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_api.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-https-listener"
  })
}

resource "aws_lb_listener" "http_redirect" {
  count             = local.alb_certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-http-redirect-listener"
  })
}

resource "aws_lb_listener" "http_forward" {
  count             = local.alb_certificate_arn == null ? 1 : 0
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_api.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-http-forward-listener"
  })
}

