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