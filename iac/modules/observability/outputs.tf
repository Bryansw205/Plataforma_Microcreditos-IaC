output "sns_topic_arn" {
  description = "ARN del topic SNS para alertas críticas."
  value       = aws_sns_topic.alerts.arn
}

output "ecs_log_group_name" {
  description = "Nombre del Log Group de ECS."
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "xray_log_group_name" {
  description = "Nombre del Log Group para X-Ray."
  value       = aws_cloudwatch_log_group.xray.name
}