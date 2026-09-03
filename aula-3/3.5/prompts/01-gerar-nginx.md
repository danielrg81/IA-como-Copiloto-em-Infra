# Prompt — Gerar infraestrutura completa para payment-api com Nginx

Papel: Engenheiro de plataforma sênior especializado em Terraform e Kubernetes.

Contexto: Cluster Kubernetes local (k3s), kubeconfig em ~/.kube/config, provider hashicorp/kubernetes ~> 2.35.
Preciso provisionar toda a infraestrutura para um serviço chamado "payment-api" usando Nginx.

Gere código Terraform completo com:

1. **Namespace** "payment" com labels (managed-by=terraform, environment=production)

2. **ResourceQuota** no namespace: max 6 pods, 1Gi de memória total

3. **LimitRange** no namespace: default limits 128Mi/200m, default requests 64Mi/100m

4. **ConfigMap** com variáveis de aplicação:
   - APP_ENV=production
   - LOG_LEVEL=info
   - SERVICE_NAME=payment-api
   - NGINX_PORT=80

5. **Secret** com credenciais (valores fictícios para lab):
   - DB_PASSWORD
   - API_KEY

6. **Deployment** "payment-api":
   - Imagem: nginx:1.27-alpine
   - 2 réplicas
   - Porta: 80
   - Resource limits: 128Mi RAM, 200m CPU
   - Resource requests: 64Mi RAM, 100m CPU
   - Liveness probe: HTTP GET / porta 80 (delay 10s, period 10s)
   - Readiness probe: HTTP GET / porta 80 (delay 5s, period 5s)
   - envFrom: ConfigMap + Secret
   - ServiceAccount dedicado

7. **Service** ClusterIP na porta 80

8. **ServiceAccount** + **Role** (permissão para ler configmaps e secrets no namespace) + **RoleBinding**

9. **NetworkPolicy** restritiva:
   - Ingress: permitir tráfego apenas de pods com label "allowed-client=true" na porta 80/TCP
   - Negar todo o restante por padrão (policy_types = Ingress)

Restrições:
- Usar variáveis para todos os valores reutilizáveis (namespace, app_name, image, replicas, porta, limits, requests)
- Marcar variáveis de secrets como sensitive = true
- Referenciar resources entre si (não hardcodar namespaces ou nomes)
- Labels consistentes em todos os resources (app, managed-by)
- Separar em 3 arquivos: main.tf, variables.tf, outputs.tf

Outputs esperados:
- Nome do namespace criado
- Nome do deployment
- Endpoint interno do serviço (name.namespace.svc.cluster.local:port)
- Nome do service account
- Nome da network policy

Formato de resposta: blocos de código separados para cada arquivo (main.tf, variables.tf, outputs.tf).
