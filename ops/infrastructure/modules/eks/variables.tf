variable "name" {
  type = string
  description = "Name"
}

variable "vpc_config" {
  description = "Global vpc config"
}

variable "assigned_security_groups" {
  type = list(string)
  default = []
}
