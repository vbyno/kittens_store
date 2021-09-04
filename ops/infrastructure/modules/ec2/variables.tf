variable "name_prefix" {
  type = string
  description = "Name prefix of the EC2 instance and all related resources"
}

variable "my_public_ip" {
  type = string
  description = "Public IP address to open SSH connection from"
}

variable "ssh_local_key_path" {
  type = string
  description = "Local path to the private SSH key to connect to EC2 instance"
}

variable "docker_compose_file_path" {
  type = string
  description = "Docker-compose file to upload on EC2 instance"
}

variable "assigned_security_groups" {
  type = list(string)
  description = "Security groups to assign"
  default = []
}

variable "database_url" {
  type = string
}

variable "vpc_config" {
  description = "Global vpc config"
}

variable "instances_number" {
  type = number

  validation {
    condition     = var.instances_number > 0 && var.instances_number < 20
    error_message = "The number of instances is limited."
  }
}

variable "app_version" {
  type = number
  description = "application version (to recreate ec2 instances)"
  default = 1
}
