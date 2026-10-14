################################################################################
# TAGS
################################################################################
tags = {
  account        = "pe-auna-test"
  region         = "us-east-1"
  description    = "Data Lake POC"
  sponsor        = "DATALAKE"
  requester      = ""
  project        = "DATALAKE"
  application    = ""
  environment    = "POC"
  createdBy      = "Wilfredo Dueñas Vallejo"
  ceco           = ""
  automatization = "terraform"
}

################################################################################
# DATA LAKE
################################################################################
datalake_prefix = "datalake"

existing_vpc_name = "VPC-BIOCELLS-POC"

existing_private_subnet_names = [
  "SUB-BIOCELLS-POC-PRI-2A",
  "SUB-BIOCELLS-POC-PRI-2B",
  "SUB-BIOCELLS-POC-PRI-3A",
  "SUB-BIOCELLS-POC-PRI-3B",
]

# Tipo de migración DMS: full-load | cdc | full-load-and-cdc
dms_migration_type = "full-load-and-cdc"
