# Código para review — contém 8 problemas intencionais
# O aluno deve usar IA para identificar os problemas antes de olhar a resposta

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
resource "kubernetes_namespace" "app" {
  metadata {
    name = "review-app"
  }
}

# --- Secret ---
# PROBLEMA: variável db_password sem sensitive=true
variable "db_password" {
  default = "production-password-123"
}

resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-secret"
    namespace = "review-app" # PROBLEMA: hardcoded, deveria ser kubernetes_namespace.app.metadata[0].name
  }

  data = {
    DB_PASSWORD = var.db_password
  }
}

# --- Role com permissões excessivas ---
resource "kubernetes_role" "app" {
  metadata {
    name      = "app-role"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  # PROBLEMA: verbs = ["*"] é permissão excessiva
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }

  # PROBLEMA: acesso a secrets com todos os verbs
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
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
    replicas = 3 # PROBLEMA: hardcoded, sem variável

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
          image = "nginx:latest" # PROBLEMA: tag :latest instável

          port {
            container_port = 80
          }

          # PROBLEMA: sem resource limits

          # PROBLEMA: sem liveness/readiness probes

          env {
            name  = "DB_PASSWORD"
            value = var.db_password # PROBLEMA: secret em env inline (deveria usar envFrom com secret)
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

# --- NetworkPolicy permissiva ---
resource "kubernetes_network_policy" "app" {
  metadata {
    name      = "allow-all"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    # PROBLEMA: pod_selector vazio = aplica a todos os pods
    pod_selector {}

    ingress {
      # PROBLEMA: sem from = aceita tráfego de qualquer origem
    }

    policy_types = ["Ingress"]
  }
}
