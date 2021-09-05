variable "vpc_config" {
  description = "Global vpc config"
}

variable "launch_template_id" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}
