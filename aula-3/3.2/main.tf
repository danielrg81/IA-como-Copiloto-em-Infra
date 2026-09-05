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
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "env"                          = "lab"
    }
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
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  data = {
    DB_PASSWORD = var.db_password
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "my-app"
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "my-app"
      "env"                          = "lab"
    }
  }

  spec {
    # Fix #9: reduzido de 3 para 1 réplica (adequado para lab)
    replicas = 1

    selector {
      match_labels = {
        app = "my-app"
      }
    }

    template {
      metadata {
        labels = {
          app                            = "my-app"
          "app.kubernetes.io/managed-by" = "terraform"
          "env"                          = "lab"
        }
      }

      spec {
        container {
          name  = "app"
          # Fix #1: tag fixa em vez de :latest
          image = "nginx:1.25-alpine"

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

          # Fix #2: senha via Secret (env_from), não em plain text
          env_from {
            secret_ref {
              name = kubernetes_secret.app.metadata[0].name
            }
          }

          # Fix #3: resource limits e requests
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

          # Fix #4: liveness probe
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 15
            failure_threshold     = 3
          }

          # Fix #4: readiness probe
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = "my-app"
    # Fix #5: namespace referenciando o resource, não string hardcoded
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
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