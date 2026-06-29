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
  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = "alb-logs"
    enabled = true
  }
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
  # --------------------------------─────────────────────────
  # CORRECCIÓN CKV_AWS_378: Cambiado de HTTP a HTTPS para asegurar
  # el cifrado completo de extremo a extremo hasta ECS Fargate.
  # ------------------------------------------------─────────
  protocol    = "HTTPS"
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

  # --------------------------------─────────────────────────
  # CORRECCIÓN CKV2_AWS_20 y CKV_AWS_2: Se eliminaron los bloques dinámicos.
  # Ahora el puerto 80 SIEMPRE redirige a HTTPS de forma incondicional.
  # ------------------------------------------------─────────
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#CORRECIÓN CKV2_AWS_28
resource "aws_wafregional_web_acl_association" "alb_waf_assoc" {
  count = var.web_acl_id != "" && var.web_acl_id != null ? 1 : 0

  resource_arn = aws_lb.main.arn
  web_acl_id   = var.web_acl_id
}