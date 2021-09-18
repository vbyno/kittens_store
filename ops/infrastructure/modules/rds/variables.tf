variable "name" {
  type = string
  description = "Name of the RDS instance"
}

variable "global_config" {
  description = "Global vpc config"
}

variable "assigned_security_groups" {
  type = list(string)
  default = []
}
