output "alb_security_group_id" {
  description = "Security Group ID for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "backend_security_group_id" {
  description = "Security Group ID for the ECS/Fargate backend."
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "Security Group ID for PostgreSQL or Aurora database."
  value       = aws_security_group.database.id
}

output "redis_security_group_id" {
  description = "Security Group ID for ElastiCache Redis."
  value       = aws_security_group.redis.id
}

output "kms_key_id" {
  description = "KMS Key ID for encryption."
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "KMS Key ARN for encryption."
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "KMS alias name."
  value       = aws_kms_alias.main.name
}

output "regional_waf_web_acl_id" {
  description = "Regional WAF Web ACL ID for ALB."
  value       = var.enable_regional_waf ? aws_wafv2_web_acl.regional[0].id : null
}

output "regional_waf_web_acl_arn" {
  description = "Regional WAF Web ACL ARN for ALB."
  value       = var.enable_regional_waf ? aws_wafv2_web_acl.regional[0].arn : null
}

output "cloudfront_waf_web_acl_id" {
  description = "CloudFront WAF Web ACL ID."
  value       = var.enable_cloudfront_waf ? aws_wafv2_web_acl.cloudfront[0].id : null
}

output "cloudfront_waf_web_acl_arn" {
  description = "CloudFront WAF Web ACL ARN."
  value       = var.enable_cloudfront_waf ? aws_wafv2_web_acl.cloudfront[0].arn : null
}