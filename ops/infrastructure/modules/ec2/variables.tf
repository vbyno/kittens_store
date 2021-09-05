variable "name_prefix" {
  type = string
  description = "Name prefix of the EC2 instance and all related resources"
}

variable "vpc_config" {
  description = "Global vpc config"
}

variable "instances_number" {
  type = number

  validation {
    condition     = var.instances_number >= 0 && var.instances_number < 20
    error_message = "The number of instances is limited."
  }
}

variable "launch_template_id" {
  type = string
}
