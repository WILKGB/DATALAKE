terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "datalake-terraform-998361628237"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "itera-aws-terraform"
    profile        = "datalake"
  }
}