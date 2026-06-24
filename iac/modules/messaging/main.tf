
# Amazon SQS – Módulo de Mensajería Desacoplada
# Implementa una cola principal con DLQ para cumplir el RNF_21:
# Retener solicitudes durante caídas de servicios externos (Infocorp API)
# y procesarlas automáticamente al restablecerse el servicio.

# 1. COLA DE MENSAJES FALLIDOS (Dead Letter Queue)
# Se crea primero porque la cola principal la referencia en su redrive_policy

resource "aws_sqs_queue" "dlq" {
  name = "${var.name_prefix}-dlq"

  # Retención máxima de 14 días para auditoría y análisis del equipo de soporte
  message_retention_seconds = var.dlq_retention_seconds

  # Cifrado en reposo con llave KMS (Seguridad – RNF 14)
  kms_master_key_id                 = var.sqs_kms_key_arn
  kms_data_key_reuse_period_seconds = 300 # Reutiliza la clave de datos 5 min para reducir costos

  tags = {
    Name        = "${var.name_prefix}-dlq"
    Environment = var.environment
    Purpose     = "Dead Letter Queue - Mensajes no procesados"
  }
}

# 2. COLA PRINCIPAL DE MENSAJES (Transacciones de Microcréditos)
# Amortiguador de alta disponibilidad entre el backend y servicios externos

resource "aws_sqs_queue" "main" {
  name = "${var.name_prefix}-queue"

  # Tiempo que un mensaje queda invisible tras ser leído por un consumidor
  # Debe superar el tiempo de procesamiento del backend para evitar duplicados
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Retención de mensajes: 4 días para garantizar el RNF_21 ante caídas prolongadas
  message_retention_seconds = var.message_retention_seconds

  # Long-polling: el consumidor espera hasta N segundos por nuevos mensajes
  # Reduce llamadas vacías a la API y optimiza costos
  receive_wait_time_seconds = var.receive_wait_time_seconds

  # Cifrado en reposo con llave KMS (Seguridad – RNF 14)
  kms_master_key_id                 = var.sqs_kms_key_arn
  kms_data_key_reuse_period_seconds = 300

  # Política de reenvío a DLQ: tras N reintentos fallidos, mover a la cola de fallidos
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = "${var.name_prefix}-queue"
    Environment = var.environment
    Purpose     = "Cola principal - Transacciones de microcréditos"
  }
}

# 3. POLÍTICA DE REENVÍO INVERSO (Redrive Allow Policy)
# Permite que solo la cola principal pueda enviar mensajes a esta DLQ

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.main.arn]
  })
}
