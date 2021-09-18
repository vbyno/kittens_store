
output "db_connection_uri" {
  sensitive = true
  value     = module.aws_rds.connection_uri
}
