provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket = "digilians-tfstate"
    key    = "terraform.tfstate"
    region = "eu-west-1" 
  }
}

