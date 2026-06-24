
# Amazon S3 Buckets

# Bucket S3 para guardar los contratos digitales firmados del microcrédito
resource "aws_s3_bucket" "documents" {
  bucket        = "${var.name_prefix}-loan-documents-s3"
  force_destroy = var.environment == "dev" ? true : false # Permite limpiar fácil en desarrollo
}

# Habilitar el control de versiones (Permite recuperar archivos modificados o borrados)
resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Cifrado con llave KMS para proteger el historial financiero
resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.s3_kms_key_arn
    }
    bucket_key_enabled = true # Reduce costos de llamadas a KMS
  }
}

# Bloqueo total de accesos públicos desde Internet para evitar filtraciones
resource "aws_s3_bucket_public_access_block" "documents" {
  bucket = aws_s3_bucket.documents.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Reglas de Ciclo de Vida: Mueve contratos antiguos a clases baratas de almacenamiento
resource "aws_s3_bucket_lifecycle_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    id     = "archiving-old-contracts"
    status = "Enabled"

    filter {}

    # A los 90 días el contrato pasa a almacenamiento de acceso poco frecuente (Standard-IA)
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    # A los 180 días se archiva de forma masiva en Glacier para cumplimiento legal histórico
    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
}  