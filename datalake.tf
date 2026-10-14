################################################################################
# DATA LAKE
# Flujo: RDS (simulado) -> DMS -> S3 raw -> Glue -> S3 clean -> Glue -> S3 curated
################################################################################

data "aws_caller_identity" "current" {}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  bucket_raw     = "${var.datalake_prefix}-raw-${local.account_id}"
  bucket_clean   = "${var.datalake_prefix}-clean-${local.account_id}"
  bucket_curated = "${var.datalake_prefix}-curated-${local.account_id}"
  # Subnets privadas de la VPC EXISTENTE (mín. 2 AZs para DMS)
  dms_subnet_ids = data.aws_subnets.private.ids
}

################################################################################
# S3 - 3 capas
################################################################################
module "s3_raw" {
  source      = "./modules/s3"
  bucket_name = local.bucket_raw
  tags        = var.tags
}

module "s3_clean" {
  source      = "./modules/s3"
  bucket_name = local.bucket_clean
  tags        = var.tags
}

module "s3_curated" {
  source      = "./modules/s3"
  bucket_name = local.bucket_curated
  tags        = var.tags
}

################################################################################
# IAM - Rol para que DMS escriba en el bucket raw (S3 target)
################################################################################
resource "aws_iam_role" "dms_s3_access" {
  name = "${var.datalake_prefix}-dms-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "dms_s3_access" {
  name = "${var.datalake_prefix}-dms-s3-access-policy"
  role = aws_iam_role.dms_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging"
        ]
        Resource = "${module.s3_raw.bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = module.s3_raw.bucket_arn
      }
    ]
  })
}

################################################################################
# DMS - instancia básica, endpoint source RDS (simulado), target S3 raw, task 1 tabla
################################################################################
module "dms" {
  source = "./modules/dms"

  name_prefix = "${var.datalake_prefix}-dms"
  subnet_ids  = local.dms_subnet_ids

  # Instancia básica
  replication_instance_class = "dms.t3.micro"
  allocated_storage          = 20

  # Endpoint source (RDS) - SIMULADO, el RDS no se crea
  source_engine_name   = "mysql"
  source_server_name   = "rds-datalake-source.simulado.local"
  source_port          = 3306
  source_username      = "dms_source_user"
  source_database_name = "sourcedb"

  # Target S3 (bucket raw)
  target_bucket_name     = module.s3_raw.bucket_name
  dms_s3_access_role_arn = aws_iam_role.dms_s3_access.arn

  # Migración (configurable desde terraform.tfvars)
  migration_type = var.dms_migration_type

  # Tabla única a replicar (simulación)
  schema_name = "public"
  table_name  = "clientes"

  tags = var.tags
}

################################################################################
# IAM - Rol para los Glue jobs
################################################################################
resource "aws_iam_role" "glue" {
  name = "${var.datalake_prefix}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "${var.datalake_prefix}-glue-s3-policy"
  role = aws_iam_role.glue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3_raw.bucket_arn,
          "${module.s3_raw.bucket_arn}/*",
          module.s3_clean.bucket_arn,
          "${module.s3_clean.bucket_arn}/*",
          module.s3_curated.bucket_arn,
          "${module.s3_curated.bucket_arn}/*"
        ]
      }
    ]
  })
}

################################################################################
# GLUE - 2 jobs: raw->clean y clean->curated
################################################################################
module "glue_raw_to_clean" {
  source = "./modules/glue"

  job_name          = "${var.datalake_prefix}-raw-to-clean"
  role_arn          = aws_iam_role.glue.arn
  scripts_bucket    = module.s3_clean.bucket_name
  script_local_path = "${path.module}/scripts/job_raw_to_clean.py"
  script_s3_key     = "scripts/job_raw_to_clean.py"
  source_bucket     = module.s3_raw.bucket_name
  target_bucket     = module.s3_clean.bucket_name

  tags = var.tags
}

module "glue_clean_to_curated" {
  source = "./modules/glue"

  job_name          = "${var.datalake_prefix}-clean-to-curated"
  role_arn          = aws_iam_role.glue.arn
  scripts_bucket    = module.s3_curated.bucket_name
  script_local_path = "${path.module}/scripts/job_clean_to_curated.py"
  script_s3_key     = "scripts/job_clean_to_curated.py"
  source_bucket     = module.s3_clean.bucket_name
  target_bucket     = module.s3_curated.bucket_name

  tags = var.tags
}
