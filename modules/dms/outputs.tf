output "replication_instance_arn" {
  description = "ARN de la replication instance"
  value       = aws_dms_replication_instance.this.replication_instance_arn
}

output "source_endpoint_arn" {
  description = "ARN del endpoint source (RDS simulado)"
  value       = aws_dms_endpoint.source.endpoint_arn
}

output "target_endpoint_arn" {
  description = "ARN del endpoint target (S3 raw)"
  value       = aws_dms_endpoint.target.endpoint_arn
}

output "replication_task_arn" {
  description = "ARN de la replication task"
  value       = aws_dms_replication_task.this.replication_task_arn
}
