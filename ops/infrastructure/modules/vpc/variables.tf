variable "name" {
  type = string
  description = "Name of the VPC"
}

variable "cidr_block" {
  type = string
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
}

variable "availability_zones" {
  type = list(string)
}
