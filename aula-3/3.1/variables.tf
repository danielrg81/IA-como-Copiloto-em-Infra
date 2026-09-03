variable "namespace" {
  description = "Namespace Kubernetes"
  type        = string
  default     = "app-production"
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "order-api"
}

variable "image" {
  description = "Imagem do container"
  type        = string
  default     = "nginx:1.25-alpine"
}

variable "replicas" {
  description = "Número de réplicas"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Porta do container"
  type        = number
  default     = 80
}

variable "cpu_limit" {
  description = "Limite de CPU"
  type        = string
  default     = "100m"
}

variable "memory_limit" {
  description = "Limite de memória"
  type        = string
  default     = "128Mi"
}

variable "log_level" {
  description = "Nível de log"
  type        = string
  default     = "info"
}

variable "quota_max_pods" {
  description = "Máximo de pods no namespace"
  type        = string
  default     = "4"
}

variable "quota_max_memory" {
  description = "Máximo de memória no namespace"
  type        = string
  default     = "512Mi"
}
