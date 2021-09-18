locals {
  rds_config = aws_db_instance.default
}

output "connection_uri" {
  description = "Full url with user/password to use in applicaiton"
  value = join("", [
    "postgres://",
    local.rds_config.username,
    ":",
    local.rds_config.password,
    "@",
    local.rds_config.endpoint,
    "/",
    local.rds_config.name,
  ])
}

output "connection_security_group_id" {
  value = aws_security_group.connection_security_group.id
}
