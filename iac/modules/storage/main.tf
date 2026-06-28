# ============================================================
# MODULE: storage (main.tf)
# Configuración segura y persistente de Amazon S3
# ============================================================

# Bucket S3 para guardar los contratos digitales firmados del microcrédito
resource "aws_s3_bucket" "documents" {
  bucket        = "${var.name_prefix}-loan-documents-s3"
  force_destroy = var.environment == "dev" ? true : false # Permite limpiar fácil en desarrollo

  # SOLUCIÓN CKV_AWS_18: Habilita el registro de accesos para auditorías inmutables
  dynamic "logging" {
    for_each = var.log_bucket_domain_name != "" ? [1] : []
    content {
      target_bucket = var.log_bucket_domain_name
      target_prefix = "s3-access-logs/"
    }
  }
}

# Habilitar el control de versiones (Permite recuperar archivos modificados o borrados)
resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration {
    status = "Enabled"
  }
}

# SOLUCIÓN CKV_AWS_144: Configura la réplica entre regiones para recuperación ante desastres
resource "aws_s3_bucket_replication_configuration" "documents" {
  # Asegura que el versionado esté listo antes de intentar configurar la réplica
  depends_on = [aws_s3_bucket_versioning.documents]

  bucket = aws_s3_bucket.documents.id
  role   = var.replication_iam_role_arn

  rule {
    id     = "replicate-all-contracts"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${var.name_prefix}-loan-documents-backup-s3"
      storage_class = "STANDARD"
    }
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

    # SOLUCIÓN CKV_AWS_300: Limpia cargas multipartes incompletas para mitigar costes ocultos
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

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

# SOLUCIÓN CKV2_AWS_62: Añadir notificaciones de eventos nativas orientadas al ecosistema de alertas
resource "aws_s3_bucket_notification" "documents_notification" {
  bucket = aws_s3_bucket.documents.id

  topic {
    topic_arn     = var.sns_topic_arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

# -------------------------------------------------------------
# Bucket para logs de ALB
# -------------------------------------------------------------
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${var.name_prefix}-alb-logs-s3"
  force_destroy = var.environment == "dev" ? true : false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SOLUCIÓN CKV2_AWS_61: Ciclo de vida para logs del ALB – evita acumulación indefinida de costos
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "archive-and-expire-alb-logs"
    status = "Enabled"

    filter {}

    # Limpia cargas multipartes incompletas
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # A los 30 días mueve logs a acceso poco frecuente (más barato)
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # A los 90 días archiva en Glacier para retención legal
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # A los 365 días elimina logs antiguos que ya no tienen valor operativo
    expiration {
      days = 365
    }
  }
}

data "aws_elb_service_account" "main" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}