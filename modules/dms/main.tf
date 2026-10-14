# Subnet group donde vive la replication instance
resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${var.name_prefix}-subnet-group"
  replication_subnet_group_description = "Subnet group para DMS del data lake"
  subnet_ids                           = var.subnet_ids

  tags = var.tags
}

# Replication instance de DMS
resource "aws_dms_replication_instance" "this" {
  replication_instance_id     = "${var.name_prefix}-instance"
  replication_instance_class  = var.replication_instance_class
  allocated_storage           = var.allocated_storage
  engine_version              = var.engine_version
  publicly_accessible         = false
  multi_az                    = false
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id

  tags = var.tags
}

# Endpoint SOURCE: apunta a un RDS (SIMULADO, no se crea el RDS)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.name_prefix}-source"
  endpoint_type = "source"
  engine_name   = var.source_engine_name

  server_name   = var.source_server_name
  port          = var.source_port
  username      = var.source_username
  password      = var.source_password
  database_name = var.source_database_name

  tags = var.tags
}

# Endpoint TARGET: bucket S3 raw
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "${var.name_prefix}-target-s3"
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name             = var.target_bucket_name
    bucket_folder           = var.target_bucket_folder
    service_access_role_arn = var.dms_s3_access_role_arn
    data_format             = "parquet"
    compression_type        = "GZIP"
  }

  tags = var.tags
}

# Replication task: full-load de una sola tabla
resource "aws_dms_replication_task" "this" {
  replication_task_id      = "${var.name_prefix}-task"
  migration_type           = var.migration_type
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn

  table_mappings = jsonencode({
    rules = [
      {
        "rule-type" = "selection"
        "rule-id"   = "1"
        "rule-name" = "1"
        "object-locator" = {
          "schema-name" = var.schema_name
          "table-name"  = var.table_name
        }
        "rule-action" = "include"
      }
    ]
  })

  tags = var.tags
}
