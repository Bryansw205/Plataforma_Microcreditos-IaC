resource "aws_sqs_queue" "processing_dlq" {
  name                      = "${local.name_prefix}-processing-dlq"
  message_retention_seconds = var.sqs_dlq_message_retention_seconds
  kms_master_key_id         = aws_kms_key.main.arn
  sqs_managed_sse_enabled   = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-processing-dlq"
    Type = "dead-letter-queue"
  })
}

resource "aws_sqs_queue" "processing" {
  name                       = "${local.name_prefix}-processing-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  kms_master_key_id          = aws_kms_key.main.arn
  sqs_managed_sse_enabled    = false

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.processing_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-processing-queue"
    Type = "main-queue"
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "processing_dlq" {
  queue_url = aws_sqs_queue.processing_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.processing.arn]
  })
}
