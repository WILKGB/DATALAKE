variable "job_name" {
  description = "Nombre del Glue job"
  type        = string
}

variable "role_arn" {
  description = "ARN del IAM role que usará el Glue job"
  type        = string
}

variable "scripts_bucket" {
  description = "Nombre del bucket donde se sube el script del job"
  type        = string
}

variable "script_local_path" {
  description = "Ruta local del script PySpark a subir"
  type        = string
}

variable "script_s3_key" {
  description = "Key (ruta) dentro del bucket donde se guarda el script"
  type        = string
}

variable "source_bucket" {
  description = "Nombre del bucket origen que lee el job"
  type        = string
}

variable "target_bucket" {
  description = "Nombre del bucket destino donde escribe el job"
  type        = string
}

variable "glue_version" {
  description = "Versión de Glue"
  type        = string
  default     = "4.0"
}

variable "worker_type" {
  description = "Tipo de worker de Glue"
  type        = string
  default     = "G.1X"
}

variable "number_of_workers" {
  description = "Número de workers"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags a aplicar"
  type        = map(string)
  default     = {}
}
