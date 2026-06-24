
# Outputs del Módulo de Respaldo

output "backup_vault_name" {
  description = "Nombre de la bóveda de respaldos de AWS Backup"
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN de la bóveda de respaldos"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "ID del plan de respaldo diario"
  value       = aws_backup_plan.daily.id
}

output "backup_plan_arn" {
  description = "ARN del plan de respaldo diario"
  value       = aws_backup_plan.daily.arn
}

output "backup_role_arn" {
  description = "ARN del rol IAM utilizado por AWS Backup para ejecutar los respaldos"
  value       = aws_iam_role.backup.arn
}
