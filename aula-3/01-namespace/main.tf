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

resource "kubernetes_namespace" "lab" {
  metadata {
    name = "ai-iac-lab"
    labels = {
      managed-by = "terraform"
      course     = "ai-iac"
    }
  }
}
