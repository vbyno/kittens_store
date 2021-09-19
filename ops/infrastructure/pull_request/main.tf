terraform {
  backend "s3" {
    bucket = "terraform-state-987045484890"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "vpc_state" {
  backend = "s3"
  config = {
    bucket = "terraform-state-987045484890"
    key    = "kittens_store/global_ci"
    region = "eu-west-3"
  }
}

data "terraform_remote_state" "live_state" {
  backend = "s3"
  config = {
    bucket = "terraform-state-987045484890"
    key    = "kittens_store/live_ci"
    region = "eu-west-3"
  }
}

locals {
  global_config = data.terraform_remote_state.vpc_state.outputs
  live_config   = data.terraform_remote_state.live_state.outputs
  db_name       = "pr-db-${var.pull_request_id}"
}

resource "random_password" "db_password" {
  length  = 14
  special = false
}

provider "kubernetes" {
  host                   = local.live_config.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.live_config.eks_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", local.live_config.eks_cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "current_namespace" {
  metadata {
    name = "pr-${var.pull_request_id}"
  }
}

resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name      = local.db_name
    namespace = kubernetes_namespace.current_namespace.metadata[0].name
  }

  data = {
    POSTGRES_DB       = "app_db"
    POSTGRES_USER     = "app_user"
    POSTGRES_PASSWORD = random_password.db_password.result
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = local.db_name
    namespace = kubernetes_namespace.current_namespace.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.db_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.db_name
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:13.3"
          port {
            container_port = 5432
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.postgres_config.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = local.db_name
    namespace = kubernetes_namespace.current_namespace.metadata[0].name
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = kubernetes_deployment.postgres.metadata[0].name
    }
    port {
      name        = "psql"
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
    }
  }
}
