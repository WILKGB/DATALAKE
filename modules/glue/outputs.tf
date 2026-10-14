output "job_name" {
  description = "Nombre del Glue job"
  value       = aws_glue_job.this.name
}

output "job_arn" {
  description = "ARN del Glue job"
  value       = aws_glue_job.this.arn
}

output "script_location" {
  description = "Ubicación del script en S3"
  value       = "s3://${var.scripts_bucket}/${aws_s3_object.script.key}"
}
