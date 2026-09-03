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

# --- Namespace ---
resource "kubernetes_namespace" "production" {
  metadata {
    name = var.namespace
    labels = {
      managed-by  = "terraform"
      environment = var.environment
    }
  }
}

# --- ResourceQuota ---
resource "kubernetes_resource_quota" "production" {
  metadata {
    name      = "${var.namespace}-quota"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  spec {
    hard = {
      pods           = var.quota_max_pods
      "limits.memory" = var.quota_max_memory
    }
  }
}

# --- ConfigMap ---
resource "kubernetes_config_map" "order_api" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  data = {
    APP_ENV   = var.environment
    LOG_LEVEL = var.log_level
  }
}

# --- Deployment ---
resource "kubernetes_deployment" "order_api" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.production.metadata[0].name
    labels = {
      app         = var.app_name
      managed-by  = "terraform"
      environment = var.environment
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = var.app_name }
    }

    template {
      metadata {
        labels = {
          app         = var.app_name
          environment = var.environment
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.image

          port {
            container_port = var.container_port
          }

          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.order_api.metadata[0].name
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# --- Service ---
resource "kubernetes_service" "order_api" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  spec {
    selector = { app = var.app_name }

    port {
      port        = 80
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
}
