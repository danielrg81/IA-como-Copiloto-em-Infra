# Prompt usado para gerar o código base (Passo 2)

Papel: Engenheiro de infraestrutura sênior com Terraform.

Contexto: Cluster k3s local, kubeconfig em ~/.kube/config.
Provider: hashicorp/kubernetes.

Gere código Terraform para:
- Namespace "app-production"
- Deployment "order-api" (nginx:1.25-alpine, 2 réplicas, limits 128Mi/100m)
- Service ClusterIP na porta 80
- ConfigMap com variáveis de ambiente (APP_ENV=production, LOG_LEVEL=info)
- ResourceQuota no namespace (max 4 pods, 512Mi RAM total)

Restrições: Usar variáveis para valores reutilizáveis. Liveness probe em /healthz.
Formato: main.tf + variables.tf + outputs.tf
