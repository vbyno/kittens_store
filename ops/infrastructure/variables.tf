variable "name" {
  type = string
  description = "A name of the project"
  default = "kittens-store"
}

variable "aws_region" {
  type = string
  description = "AWS Region to provision the infrastructure in"
  default = "eu-west-3"
}

variable "cidr_block" {
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  default = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type = list(string)
  default = [
    "eu-west-3a",
    "eu-west-3b"
  ]
}
