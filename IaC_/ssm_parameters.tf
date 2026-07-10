resource "aws_ssm_parameter" "frontend_bucket_name" {
  name        = "/${local.name_prefix}/frontend/bucket_name"
  description = "Nombre del bucket S3 del frontend para el CI/CD"
  type        = "String"
  value       = aws_s3_bucket.frontend.id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "cloudfront_distribution_id" {
  name        = "/${local.name_prefix}/frontend/cloudfront_id"
  description = "ID de la distribucion CloudFront para invalidar cache"
  type        = "String"
  value       = aws_cloudfront_distribution.main.id

  tags = local.common_tags
}
