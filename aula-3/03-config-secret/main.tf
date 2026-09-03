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

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = "ai-iac-lab"
  }

  data = {
    APP_ENV      = "lab"
    LOG_LEVEL    = "debug"
    SERVICE_NAME = "demo-app"
  }
}

resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "app-secret"
    namespace = "ai-iac-lab"
  }

  data = {
    DB_PASSWORD = "lab-password-123"
    API_KEY     = "fake-key-for-testing"
  }
}

resource "kubernetes_pod" "demo" {
  metadata {
    name      = "demo-app"
    namespace = "ai-iac-lab"
  }

  spec {
    container {
      name    = "demo"
      image   = "busybox:1.36"
      command = ["sh", "-c", "env | sort && sleep 3600"]

      env_from {
        config_map_ref {
          name = kubernetes_config_map.app_config.metadata[0].name
        }
      }

      env_from {
        secret_ref {
          name = kubernetes_secret.app_secret.metadata[0].name
        }
      }
    }
  }
}
