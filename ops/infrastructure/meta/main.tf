provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "${var.name}-terraform-state-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}

# resource "aws_s3_bucket" "bucket" {
#   bucket = "kittens_store"
#   versioning {
#     enabled = true
#   }
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
#   object_lock_configuration {
#     object_lock_enabled = "Enabled"
#   }
#   tags = {
#     Name = "S3 Remote Terraform State Store"
#   }
# }
