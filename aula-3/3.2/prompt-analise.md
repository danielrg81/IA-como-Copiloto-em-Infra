# Prompt para análise do código legado

Papel: Engenheiro de plataforma sênior fazendo code review de Terraform.

Contexto: Este código Terraform gerencia recursos em um cluster k3s local
via provider hashicorp/kubernetes. O código já está aplicado (existe state).
Preciso refatorar sem causar downtime.

Código atual:

```hcl
resource "kubernetes_namespace" "ns" {
  metadata { name = "legacy-app" }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "my-app"
    namespace = "legacy-app"
  }
  spec {
    replicas = 3
    selector { match_labels = { app = "my-app" } }
    template {
      metadata { labels = { app = "my-app" } }
      spec {
        container {
          name  = "app"
          image = "nginx:latest"
          port { container_port = 80 }
          env {
            name  = "DB_PASSWORD"
            value = "super-secret-123"
          }
          env {
            name  = "APP_ENV"
            value = "production"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = "my-app"
    namespace = "legacy-app"
  }
  spec {
    selector = { app = "my-app" }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}
```

Analise e identifique:
- Valores hardcoded que deveriam ser variáveis
- Problemas de segurança (secrets expostos, imagens sem tag fixa, falta de resource limits)
- Falta de boas práticas (probes, labels, outputs)
- Riscos de refactoring (o que pode causar recreate de resources)

Formato: Lista de findings com severidade (alta/média/baixa) e sugestão de fix para cada um.
Restrições: As mudanças NÃO podem causar destroy de resources existentes.
