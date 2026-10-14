variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "tags" {
  description = "Tags a aplicar al bucket"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Permitir borrar el bucket aunque tenga objetos (útil en POC)"
  type        = bool
  default     = true
}
