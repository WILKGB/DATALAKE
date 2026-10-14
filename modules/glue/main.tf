# Sube el script PySpark del job al bucket de scripts
resource "aws_s3_object" "script" {
  bucket = var.scripts_bucket
  key    = var.script_s3_key
  source = var.script_local_path
  etag   = filemd5(var.script_local_path)

  tags = var.tags
}

# Glue job que lee del bucket origen y escribe en el bucket destino
resource "aws_glue_job" "this" {
  name              = var.job_name
  role_arn          = var.role_arn
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers

  command {
    name            = "glueetl"
    script_location = "s3://${var.scripts_bucket}/${aws_s3_object.script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--SOURCE_BUCKET"       = var.source_bucket
    "--TARGET_BUCKET"       = var.target_bucket
    "--enable-metrics"      = "true"
    "--enable-job-insights" = "true"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--TempDir"             = "s3://${var.scripts_bucket}/tmp/"
  }

  tags = var.tags
}
