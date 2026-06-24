output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront."
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "ARN de la distribución CloudFront."
  value       = aws_cloudfront_distribution.frontend.arn
}

output "cloudfront_domain_name" {
  description = "Dominio asignado por CloudFront."
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "Hosted Zone ID de CloudFront para crear alias en Route 53."
  value       = aws_cloudfront_distribution.frontend.hosted_zone_id
}

output "origin_access_control_id" {
  description = "ID del Origin Access Control asociado al bucket frontend."
  value       = aws_cloudfront_origin_access_control.frontend.id
}