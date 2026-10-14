variable "name_prefix" {
  description = "Prefijo para nombrar los recursos DMS"
  type        = string
  default     = "datalake-dms"
}

variable "subnet_ids" {
  description = "Lista de subnet IDs para el subnet group de DMS"
  type        = list(string)
}

variable "replication_instance_class" {
  description = "Clase de la replication instance de DMS"
  type        = string
  default     = "dms.t3.micro"
}

variable "allocated_storage" {
  description = "Almacenamiento (GB) de la replication instance"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "Versión del engine de DMS"
  type        = string
  default     = "3.5.3"
}

# ---- Parámetros del endpoint SOURCE (RDS) - SIMULADO ----
# El RDS no se crea; solo se define un endpoint source que apunta a datos ficticios.
variable "source_engine_name" {
  description = "Motor del origen (ej. mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "source_server_name" {
  description = "Host del RDS origen (simulado)"
  type        = string
  default     = "rds-datalake-source.simulado.local"
}

variable "source_port" {
  description = "Puerto del RDS origen"
  type        = number
  default     = 3306
}

variable "source_username" {
  description = "Usuario del RDS origen (simulado)"
  type        = string
  default     = "dms_source_user"
}

variable "source_password" {
  description = "Password del RDS origen (simulado)"
  type        = string
  default     = "SimulatedPassw0rd!"
  sensitive   = true
}

variable "source_database_name" {
  description = "Base de datos origen (simulada)"
  type        = string
  default     = "sourcedb"
}

# ---- Target S3 ----
variable "target_bucket_name" {
  description = "Bucket S3 destino (raw) donde DMS escribe la data"
  type        = string
}

variable "target_bucket_folder" {
  description = "Carpeta dentro del bucket destino"
  type        = string
  default     = "dms"
}

variable "dms_s3_access_role_arn" {
  description = "ARN del IAM role que DMS usa para escribir en S3"
  type        = string
}

# ---- Task / tabla a replicar ----
variable "migration_type" {
  description = "Tipo de migración: full-load, cdc o full-load-and-cdc"
  type        = string
  default     = "full-load-and-cdc"

  validation {
    condition     = contains(["full-load", "cdc", "full-load-and-cdc"], var.migration_type)
    error_message = "migration_type debe ser uno de: full-load, cdc, full-load-and-cdc."
  }
}

variable "schema_name" {
  description = "Schema de la tabla a replicar"
  type        = string
  default     = "public"
}

variable "table_name" {
  description = "Tabla única a replicar (simulación con una sola tabla)"
  type        = string
  default     = "clientes"
}

variable "tags" {
  description = "Tags a aplicar"
  type        = map(string)
  default     = {}
}
