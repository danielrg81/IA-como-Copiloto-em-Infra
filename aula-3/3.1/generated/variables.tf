variable "namespace" {
  type    = string
  default = "app-production"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "app_name" {
  type    = string
  default = "order-api"
}

variable "image" {
  type    = string
  default = "nginx:1.25-alpine"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu_limit" {
  type    = string
  default = "100m"
}

variable "memory_limit" {
  type    = string
  default = "128Mi"
}

variable "log_level" {
  type    = string
  default = "info"
}

variable "quota_max_pods" {
  type    = string
  default = "4"
}

variable "quota_max_memory" {
  type    = string
  default = "512Mi"
}
