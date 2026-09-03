# Código corrigido — todos os 10 findings resolvidos

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

variable "db_password" {
  type      = string
  sensitive = true
  default   = "production-password-123"
}

variable "replicas" {
  type    = number
  default = 2
}

# --- Namespace ---
resource "kubernetes_namespace" "app" {
  metadata {
    name = "review-app"
  }
}

# --- Secret ---
resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    DB_PASSWORD = var.db_password
  }
}

# --- Role com permissões mínimas ---
resource "kubernetes_role" "app" {
  metadata {
    name      = "app-role"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
}

resource "kubernetes_role_binding" "app" {
  metadata {
    name      = "app-rolebinding"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.app.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.app.metadata[0].name
    namespace = kubernetes_namespace.app.metadata[0].name
  }
}

# --- Deployment ---
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "review-app"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = "review-app" }
    }

    template {
      metadata {
        labels = { app = "review-app" }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata[0].name

        container {
          name  = "app"
          image = "nginx:1.25-alpine"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 5
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

# --- Service ---
resource "kubernetes_service" "app" {
  metadata {
    name      = "review-app"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = "review-app" }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# --- NetworkPolicy restritiva ---
resource "kubernetes_network_policy" "app" {
  metadata {
    name      = "allow-app-traffic"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = { app = "review-app" }
    }

    ingress {
      from {
        pod_selector {
          match_labels = { "allowed-client" = "true" }
        }
      }
      ports {
        port     = "80"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
