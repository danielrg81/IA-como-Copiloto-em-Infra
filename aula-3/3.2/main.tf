# Código "legado" — propositalmente ruim
# Problemas intencionais para o aluno identificar com ajuda da IA:
# - Imagem com tag :latest
# - Secret em plain text no código
# - Sem resource limits
# - Sem probes (liveness/readiness)
# - Sem labels úteis (managed-by, version)
# - Namespace hardcoded em string (não referencia o resource)
# - Sem outputs
# - Sem variables (tudo hardcoded)
# - Réplicas excessivas para um lab (3)

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "legacy-app"
  }
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "super-secret-123"
}

resource "kubernetes_secret" "app" {
  metadata {
    name      = "my-app-secret"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  data = {
    DB_PASSWORD = var.db_password
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "my-app"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "my-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }

      spec {
        container {
          name  = "app"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          env {
            name  = "APP_ENV"
            value = "production"
          }

          env {
            name  = "LOG_LEVEL"
            value = "info"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = "my-app"
    namespace = "legacy-app"
  }

  spec {
    selector = {
      app = "my-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
