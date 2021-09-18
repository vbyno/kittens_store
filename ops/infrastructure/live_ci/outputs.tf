output "database_url" {
  sensitive = true
  value     = module.aws_rds.connection_uri
}

output "eks_cluster_name" {
  value = module.aws_eks.cluster_name
}

output "eks_certificate_authority" {
  sensitive = true
  value     = module.aws_eks.certificate_authority
}

output "eks_cluster_endpoint" {
  value = module.aws_eks.endpoint
}
