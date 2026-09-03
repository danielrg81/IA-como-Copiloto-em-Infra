# Prompt: Geração de Deployment Kubernetes

## Descrição
Gerar manifests Kubernetes (Deployment + Service) prontos para apply no k3s.

## Template

```
Papel: Você é um engenheiro de infraestrutura senior especializado em Kubernetes.

Contexto: Cluster k3s single-node para lab. Namespace: {{NAMESPACE}}.
Naming convention: {{NAMING_CONVENTION}}

Instrução: Crie os manifests Kubernetes para o serviço abaixo.

Specs:
- Nome: {{SERVICE_NAME}}
- Imagem: {{IMAGE}}
- Porta: {{PORT}}
- Replicas: {{REPLICAS}}
- Args: {{ARGS}}
- Resources limits: CPU={{CPU_LIMIT}}, memory={{MEM_LIMIT}}
- Liveness probe: {{LIVENESS_PATH}}
- Labels: app, version, managed-by

Restrições:
- YAML válido pronto para kubectl apply
- Incluir resource limits (obrigatório)
- Incluir liveness e readiness probes
- SecurityContext com runAsNonRoot
- Não usar latest como tag

Formato de saída: 
- deployment.yaml
- service.yaml
Separados por ---
```

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: Engenheiro de infra senior em Kubernetes.

Contexto: k3s single-node, namespace ai-iac-lab. Naming: {app}-{recurso}.

Crie manifests Kubernetes:
- Nome: order-api
- Imagem: hashicorp/http-echo:0.2.3
- Porta: 5678
- Replicas: 2
- Args: [\"-text=order-api running\"]
- Limits: CPU=100m, memory=128Mi
- Liveness: GET / porta 5678
- Labels: app=order-api, version=0.2.3, managed-by=kiro

Restrições: YAML válido, resource limits, probes, runAsNonRoot, sem latest.
Formato: deployment.yaml + service.yaml separados por ---"
```

## Validação

```bash
# Salvar output
kiro chat "..." > /tmp/order-api.yaml

# Validar sintaxe
kubectl apply -f /tmp/order-api.yaml --dry-run=server -n ai-iac-lab

# Aplicar
kubectl apply -f /tmp/order-api.yaml -n ai-iac-lab

# Verificar
kubectl get pods -n ai-iac-lab
kubectl get svc -n ai-iac-lab
```
