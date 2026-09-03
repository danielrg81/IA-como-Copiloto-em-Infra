# Versão corrigida — resultado esperado após aplicar todos os fixes

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

variable "namespace" {
  description = "Namespace da aplicação"
  type        = string
  default     = "review-app"
}

variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "review-app"
}

variable "image" {
  description = "Imagem do container com tag fixa"
  type        = string
  default     = "nginx:1.25-alpine"
}

variable "replicas" {
  description = "Número de réplicas"
  type        = number
  default     = 2
}

variable "db_password" {
  description = "Password do banco de dados"
  type        = string
  sensitive   = true
  default     = "production-password-123"
}

# --- Namespace ---
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      managed-by = "terraform"
    }
  }
}

# --- Secret (via resource, não env inline) ---
resource "kubernetes_secret" "app" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    DB_PASSWORD = var.db_password
  }
}

# --- Role com permissões mínimas ---
resource "kubernetes_role" "app" {
  metadata {
    name      = "${var.app_name}-role"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }
}

resource "kubernetes_service_account" "app" {
  metadata {
    name      = "${var.app_name}-sa"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
}

resource "kubernetes_role_binding" "app" {
  metadata {
    name      = "${var.app_name}-rolebinding"
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
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app        = var.app_name
      managed-by = "terraform"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = { app = var.app_name }
    }

    template {
      metadata {
        labels = { app = var.app_name }
      }

      spec {
        service_account_name = kubernetes_service_account.app.metadata[0].name

        container {
          name  = "app"
          image = var.image

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

          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata[0].name
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
        }
      }
    }
  }
}

# --- Service ---
resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = var.app_name }

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
    name      = "${var.app_name}-policy"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = { app = var.app_name }
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
