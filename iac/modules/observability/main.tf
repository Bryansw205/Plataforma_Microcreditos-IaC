# ============================================================
# MODULE: observability
# CloudWatch Logs, Métricas, Alarmas, SNS y X-Ray
# ============================================================
resource "aws_sns_topic" "alerts" {
  name              = "${var.project}-${var.environment}-critical-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name        = "${var.project}-${var.environment}-critical-alerts"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/aws/ecs/${var.project}-${var.environment}/app"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = {
    Name        = "${var.project}-${var.environment}-ecs-logs"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "xray" {
  name              = "/aws/xray/${var.project}-${var.environment}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = {
    Name        = "${var.project}-${var.environment}-xray-logs"
    Project     = var.project
    Environment = var.environment
  }
}

# CPU > 85%
resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.project}-${var.environment}-ecs-high-cpu"
  alarm_description   = "Alerta cuando el uso de CPU en ECS supera el 85%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  threshold           = 85
  statistic           = "Average"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Memoria > 85%
resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  alarm_name          = "${var.project}-${var.environment}-ecs-high-memory"
  alarm_description   = "Alerta cuando el uso de memoria en ECS supera el 85%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  threshold           = 85
  statistic           = "Average"
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Errores 5XX del ALB
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project}-${var.environment}-alb-5xx-errors"
  alarm_description   = "Alerta cuando el ALB detecta errores 5XX."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  threshold           = 10
  statistic           = "Sum"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Targets no saludables
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${var.project}-${var.environment}-alb-unhealthy-targets"
  alarm_description   = "Alerta cuando existen targets no saludables detrás del ALB."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 0
  statistic           = "Average"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Latencia del ALB
resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "${var.project}-${var.environment}-alb-high-latency"
  alarm_description   = "Alerta cuando la latencia promedio del ALB supera los 400 ms."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  threshold           = 0.4
  statistic           = "Average"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}