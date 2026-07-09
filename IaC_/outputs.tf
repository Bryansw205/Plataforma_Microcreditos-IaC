output "kms_key_id" {
  description = "ID de la clave KMS principal del proyecto"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN de la clave KMS principal del proyecto"
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "Alias de la clave KMS principal"
  value       = aws_kms_alias.main.name
}

output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR de la VPC principal"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "Zonas de disponibilidad usadas por la infraestructura"
  value       = data.aws_availability_zones.available.names
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "IDs de las subredes privadas de aplicación"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "IDs de las subredes privadas de datos"
  value       = aws_subnet.private_data[*].id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs de los NAT Gateway"
  value       = aws_nat_gateway.main[*].id
}

output "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "ecs_api_security_group_id" {
  description = "ID del Security Group del ECS API Service"
  value       = aws_security_group.ecs_api.id
}

output "ecs_worker_security_group_id" {
  description = "ID del Security Group del ECS Worker Service"
  value       = aws_security_group.ecs_worker.id
}

output "aurora_security_group_id" {
  description = "ID del Security Group de Aurora PostgreSQL"
  value       = aws_security_group.aurora.id
}

output "redis_security_group_id" {
  description = "ID del Security Group de Redis"
  value       = aws_security_group.redis.id
}

output "sqs_processing_queue_url" {
  description = "URL de la cola principal de procesamiento"
  value       = aws_sqs_queue.processing.id
}

output "sqs_processing_queue_arn" {
  description = "ARN de la cola principal de procesamiento"
  value       = aws_sqs_queue.processing.arn
}

output "sqs_processing_dlq_url" {
  description = "URL de la Dead-Letter Queue"
  value       = aws_sqs_queue.processing_dlq.id
}

output "sqs_processing_dlq_arn" {
  description = "ARN de la Dead-Letter Queue"
  value       = aws_sqs_queue.processing_dlq.arn
}

output "alerts_topic_name" {
  description = "Nombre del topico SNS de alertas"
  value       = aws_sns_topic.alerts.name
}

output "alerts_topic_arn" {
  description = "ARN del topico SNS de alertas"
  value       = aws_sns_topic.alerts.arn
}

output "parameter_tasa_interes_name" {
  description = "Nombre del parametro de tasa de interes"
  value       = aws_ssm_parameter.tasa_interes.name
}

output "parameter_limite_creditos_name" {
  description = "Nombre del parametro de limite de creditos"
  value       = aws_ssm_parameter.limite_creditos.name
}


output "aurora_cluster_id" {
  description = "ID del cluster Aurora PostgreSQL"
  value       = aws_rds_cluster.aurora.id
}

output "aurora_cluster_arn" {
  description = "ARN del cluster Aurora PostgreSQL"
  value       = aws_rds_cluster.aurora.arn
}

output "aurora_writer_endpoint" {
  description = "Endpoint principal del cluster Aurora para lecturas y escrituras"
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_reader_endpoint" {
  description = "Endpoint de lectura del cluster Aurora"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "aurora_database_name" {
  description = "Nombre de la base de datos principal"
  value       = aws_rds_cluster.aurora.database_name
}

output "aurora_port" {
  description = "Puerto de Aurora PostgreSQL"
  value       = aws_rds_cluster.aurora.port
}

output "aurora_master_secret_arn" {
  description = "ARN del secreto administrado por RDS para el usuario maestro"
  value       = aws_rds_cluster.aurora.master_user_secret[0].secret_arn
  sensitive   = true
}

output "parameter_plazo_maximo_name" {
  description = "Nombre del parametro de plazo maximo"
  value       = aws_ssm_parameter.plazo_maximo.name
}


output "alb_arn" {
  description = "ARN del Application Load Balancer de la API"
  value       = aws_lb.api.arn
}

output "alb_dns_name" {
  description = "DNS publico del Application Load Balancer de la API"
  value       = aws_lb.api.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del Application Load Balancer"
  value       = aws_lb.api.zone_id
}

output "ecs_api_target_group_arn" {
  description = "ARN del Target Group del ECS API Service"
  value       = aws_lb_target_group.ecs_api.arn
}

output "ecs_api_target_group_name" {
  description = "Nombre del Target Group del ECS API Service"
  value       = aws_lb_target_group.ecs_api.name
}

output "alb_https_listener_arn" {
  description = "ARN del listener HTTPS del ALB"
  value       = local.alb_certificate_arn != null ? aws_lb_listener.https[0].arn : null
}

output "cloudfront_certificate_arn" {
  description = "ARN del certificado ACM para CloudFront"
  value       = length(aws_acm_certificate.cloudfront) > 0 ? aws_acm_certificate.cloudfront[0].arn : ""
}

output "alb_certificate_arn" {
  description = "ARN del certificado ACM para el ALB"
  value       = var.aws_region == "us-east-1" ? (length(aws_acm_certificate.cloudfront) > 0 ? aws_acm_certificate.cloudfront[0].arn : "") : (length(aws_acm_certificate.alb) > 0 ? aws_acm_certificate.alb[0].arn : "")
}

