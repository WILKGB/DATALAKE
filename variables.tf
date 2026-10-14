variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Profile a utilizar para desplegar los recursos en AWS"
  default     = "datalake"
}

variable "tags" {
  type = object({
    account        = string
    region         = string
    description    = string
    sponsor        = string
    requester      = string
    project        = string
    application    = string
    environment    = string
    createdBy      = string
    ceco           = string
    automatization = string
  })
  default = {
    account        = ""
    region         = ""
    description    = ""
    sponsor        = ""
    requester      = ""
    project        = ""
    application    = ""
    environment    = ""
    createdBy      = ""
    ceco           = ""
    automatization = ""
  }
}

################################################################################
# DATA LAKE
################################################################################
variable "datalake_prefix" {
  description = "Prefijo para nombrar los recursos del data lake (buckets, roles, dms, glue)"
  type        = string
  default     = "datalake"
}

variable "existing_vpc_name" {
  description = "Nombre (tag Name) de la VPC existente a usar"
  type        = string
  default     = "VPC-BIOCELLS-POC"
}

variable "existing_private_subnet_names" {
  description = "Nombres (tag Name) de las subnets privadas existentes para DMS (mín. 2 AZs)"
  type        = list(string)
  default = [
    "SUB-BIOCELLS-POC-PRI-2A",
    "SUB-BIOCELLS-POC-PRI-2B",
    "SUB-BIOCELLS-POC-PRI-3A",
    "SUB-BIOCELLS-POC-PRI-3B",
  ]
}

variable "dms_migration_type" {
  description = "Tipo de migración DMS: full-load, cdc o full-load-and-cdc"
  type        = string
  default     = "full-load-and-cdc"

  validation {
    condition     = contains(["full-load", "cdc", "full-load-and-cdc"], var.dms_migration_type)
    error_message = "dms_migration_type debe ser uno de: full-load, cdc, full-load-and-cdc."
  }
}
