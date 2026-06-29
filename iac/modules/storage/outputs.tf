output "documents_bucket_id" {
  description = "Nombre único del bucket S3 de documentos"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "Identificador ARN único del bucket de documentos"
  value       = aws_s3_bucket.documents.arn
}

output "alb_logs_bucket_id" {
  description = "Nombre único del bucket S3 de logs del ALB"
  value       = aws_s3_bucket.alb_logs.id
}