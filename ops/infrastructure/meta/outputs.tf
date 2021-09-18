output "terraform_state_lock_table" {
  value = aws_dynamodb_table.terraform_state_lock.name
}
