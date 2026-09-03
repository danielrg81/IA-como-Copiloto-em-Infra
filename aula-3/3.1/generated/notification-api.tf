variable "namespace_notification" {
  type    = string
  default = "ai-iac-lab"
}

variable "notification_app_name" {
  type    = string
  default = "notification-api-v2"
}

variable "notification_image" {
  type    = string
  default = "hashicorp/http-echo:0.2.3"
}

variable "notification_app_version" {
  type    = string
  default = "0.2.3"
}

variable "notification_replicas" {
  type    = number
  default = 2
}

variable "notification_port" {
  type    = number
  default = 5678
}

variable "notification_cpu_limit" {
  type    = string
  default = "100m"
}

variable "notification_memory_limit" {
  type    = string
  default = "128Mi"
}

resource "kubernetes_deployment" "notification_api" {
  metadata {
    name      = var.notification_app_name
    namespace = var.namespace_notification
  }
  spec {
    replicas = var.notification_replicas
    selector {
      match_labels = { app = var.notification_app_name }
    }
    template {
      metadata {
        labels = {
          app     = var.notification_app_name
          version = var.notification_app_version
        }
      }
      spec {
        container {
          name  = var.notification_app_name
          image = var.notification_image
          args  = ["-text=${var.notification_app_name} running"]
          port {
            container_port = var.notification_port
          }
          resources {
            limits = {
              cpu    = var.notification_cpu_limit
              memory = var.notification_memory_limit
            }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = var.notification_port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "notification_api" {
  metadata {
    name      = var.notification_app_name
    namespace = var.namespace_notification
  }
  spec {
    selector = { app = var.notification_app_name }
    port {
      port        = var.notification_port
      target_port = var.notification_port
    }
    type = "ClusterIP"
  }
}
