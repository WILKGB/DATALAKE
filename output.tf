################################################################################
# VPC EXISTENTE
################################################################################
output "vpc_id" {
  description = "ID de la VPC existente usada"
  value       = data.aws_vpc.existing.id
}

output "dms_private_subnet_ids" {
  description = "Subnets privadas existentes usadas por DMS"
  value       = data.aws_subnets.private.ids
}

################################################################################
# DATA LAKE
################################################################################
output "datalake_bucket_raw" {
  description = "Bucket S3 capa raw (data cruda desde DMS)"
  value       = module.s3_raw.bucket_name
}

output "datalake_bucket_clean" {
  description = "Bucket S3 capa clean (data limpia)"
  value       = module.s3_clean.bucket_name
}

output "datalake_bucket_curated" {
  description = "Bucket S3 capa curated (data lista para consumo)"
  value       = module.s3_curated.bucket_name
}

output "dms_replication_instance_arn" {
  description = "ARN de la replication instance de DMS"
  value       = module.dms.replication_instance_arn
}

output "dms_source_endpoint_arn" {
  description = "ARN del endpoint source (RDS simulado)"
  value       = module.dms.source_endpoint_arn
}

output "dms_target_endpoint_arn" {
  description = "ARN del endpoint target (S3 raw)"
  value       = module.dms.target_endpoint_arn
}

output "dms_replication_task_arn" {
  description = "ARN de la replication task"
  value       = module.dms.replication_task_arn
}

output "glue_job_raw_to_clean" {
  description = "Nombre del Glue job raw->clean"
  value       = module.glue_raw_to_clean.job_name
}

output "glue_job_clean_to_curated" {
  description = "Nombre del Glue job clean->curated"
  value       = module.glue_clean_to_curated.job_name
}
