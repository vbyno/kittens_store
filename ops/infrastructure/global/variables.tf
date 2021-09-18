variable "name" {
  type        = string
  description = "A name of the project"
  default     = "kittens-store"
}

variable "aws_region" {
  type        = string
  description = "AWS Region to provision the infrastructure in"
  default     = "eu-west-3"
}
