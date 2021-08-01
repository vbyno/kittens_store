variable "name_prefix" {
  type = string
  description = "Name prefix of the EC2 instance and all related resources"
}

variable "vpc_id" {
  type = string
  description = "VPC Id"
}

variable "my_public_ip" {
  type = string
  description = "Public IP address to open SSH connection from"
}

variable "ssh_local_key_path" {
  type = string
  description = "Local path to the private SSH key to connect to EC2 instance"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID"
}

variable "docker_compose_file_path" {
  type = string
  description = "Docker-compose file to upload on EC2 instance"
}
