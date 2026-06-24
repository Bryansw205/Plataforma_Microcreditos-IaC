
# Outputs del Módulo de Mensajería

# ─── Cola Principal ───

output "queue_id" {
  description = "URL de la cola SQS principal (usada por el backend para enviar/recibir mensajes)"
  value       = aws_sqs_queue.main.id
}

output "queue_arn" {
  description = "ARN de la cola SQS principal"
  value       = aws_sqs_queue.main.arn
}

output "queue_name" {
  description = "Nombre de la cola SQS principal"
  value       = aws_sqs_queue.main.name
}

# ─── Dead Letter Queue ───

output "dlq_id" {
  description = "URL de la Dead Letter Queue"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "ARN de la Dead Letter Queue"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "Nombre de la Dead Letter Queue"
  value       = aws_sqs_queue.dlq.name
}
