variable "name" {
  type = string
  description = "Name"
}

variable "ec2_instance_ids" {
  type = list(string)
  description = "ids of ec2 instances to balance a load"
}

variable "vpc_config" {
  description = "Global vpc config"
}
