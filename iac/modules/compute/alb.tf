# ─────────────────────────────────────────────────────────
# Application Load Balancer (ALB)
# ─────────────────────────────────────────────────────────

resource "aws_lb" "main" {
  #checkov:skip=CKV_AWS_150: Deletion protection is intentionally parameterized for prod only to allow dev teardown.
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  drop_invalid_header_fields = true

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = {
    Name        = "${var.name_prefix}-alb"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────────────────
# Target Group
# ─────────────────────────────────────────────────────────

resource "aws_lb_target_group" "app" {
  name        = "${var.name_prefix}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Requerido para Fargate awsvpc

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  tags = {
    Name        = "${var.name_prefix}-tg"
    Environment = var.environment
  }
}

# ─────────────────────────────────────────────────────────
# Listeners
# ─────────────────────────────────────────────────────────

resource "aws_lb_listener" "https" {
  count = var.acm_certificate_arn != "" && var.acm_certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.acm_certificate_arn != "" && var.acm_certificate_arn != null ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.acm_certificate_arn == "" || var.acm_certificate_arn == null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
  }
}
