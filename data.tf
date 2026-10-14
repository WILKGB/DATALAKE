################################################################################
# VPC EXISTENTE (no se crea, se referencia la que ya existe en la cuenta)
################################################################################
data "aws_vpc" "existing" {
  tags = {
    Name = var.existing_vpc_name
  }
}

# Subnets privadas existentes de esa VPC (por sus nombres exactos vía tag:Name)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Name"
    values = var.existing_private_subnet_names
  }
}
