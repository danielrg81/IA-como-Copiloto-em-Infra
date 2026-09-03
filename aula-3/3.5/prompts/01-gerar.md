# Prompt 1 — Gerar infraestrutura completa para payment-api

Papel: Engenheiro de plataforma sênior com Terraform.

Contexto: Cluster k3s local, kubeconfig em ~/.kube/config, provider hashicorp/kubernetes ~> 2.35.
Preciso provisionar toda a infraestrutura para um novo serviço chamado "payment-api".

Gere código Terraform com:

1. Namespace "payment" com labels (managed-by=terraform, environment=production)
2. ResourceQuota: max 6 pods, 1Gi de memória total
3. LimitRange: default limits 128Mi/100m, default requests 64Mi/50m
4. ConfigMap com: APP_ENV=production, LOG_LEVEL=info, SERVICE_NAME=payment-api
5. Secret com: DB_PASSWORD, API_KEY (valores fictícios para lab)
6. Deployment "payment-api":
   - Imagem: hashicorp/http-echo:0.2.3
   - Args: ["-text=payment-api running"]
   - Porta: 5678
   - 2 réplicas
   - Resource limits: 128Mi RAM, 100m CPU
   - Resource requests: 64Mi RAM, 50m CPU
   - Liveness probe: GET / porta 5678 (delay 5s, period 10s)
   - Readiness probe: GET / porta 5678 (delay 3s, period 5s)
   - envFrom: ConfigMap + Secret
   - ServiceAccount dedicado
7. Service ClusterIP na porta 5678
8. ServiceAccount + Role (ler configmaps e secrets no namespace) + RoleBinding
9. NetworkPolicy: permitir ingress apenas de pods com label "allowed-client=true" ou do namespace "ai-iac-lab", porta 5678 TCP

Restrições:
- Usar variáveis para valores reutilizáveis (namespace, app_name, image, replicas, porta, limits)
- Marcar variáveis de secrets como sensitive = true
- Referenciar resources entre si (não hardcodar namespaces/nomes)
- Labels consistentes em todos os resources
- Separar em 3 arquivos: main.tf, variables.tf, outputs.tf
- Outputs: namespace, deployment name, service endpoint, service account, network policy

Formato de resposta: blocos de código separados para cada arquivo.
