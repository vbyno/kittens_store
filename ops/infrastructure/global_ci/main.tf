terraform {
  backend "s3" {
    bucket = "terraform-state-987045484890"
    region = "eu-west-3"
    key    = "kittens_store/global_ci"
    dynamodb_table = "kittens-store-terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "aws_vpc" {
  source = "../modules/vpc"

  name = "dogs-vpc"
  cidr_block = "10.1.0.0/16"
  availability_zones = data.aws_availability_zones.available.names
}
