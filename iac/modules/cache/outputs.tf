output "redis_endpoint" {
  description = "Dirección del nodo primario de Redis para la aplicación"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_replication_group_id" {
  description = "ID del grupo de replicación de Redis"
  value       = aws_elasticache_replication_group.main.id
}