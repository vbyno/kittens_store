variable "name" {
  type = string
  description = "Name of the VPC"
}

variable "cidr_block" {
  type = string
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  default = "10.1.0.0/16"
}

variable "subnets_number" {
  type = number
  description = "Number of subnets to create"
  default = 2

  validation {
    condition     = var.subnets_number > 0 && var.subnets_number < 256
    error_message = "The number of subnets is limited."
  }
}
