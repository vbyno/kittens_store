output "eks_cluster_name" {
  value = local.live_config.eks_cluster_name
}

output "database_url" {
  sensitive = true
  value     = "postgres://app_user:${random_password.db_password.result}@${kubernetes_service.postgres.spec[0].cluster_ip}:5432/app_db"
}

output "k8s_namespace" {
  value = kubernetes_namespace.current_namespace.metadata[0].name
}
