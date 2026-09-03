# Prompt: Geração de Deployment + Service Kubernetes

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

Formato de saída: deployment.yaml + service.yaml separados por ---
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| NAMESPACE | Namespace alvo | ai-iac-lab |
| NAMING_CONVENTION | Padrão de nomes | {app}-{recurso} |
| SERVICE_NAME | Nome do serviço | notification-api |
| IMAGE | Imagem Docker | hashicorp/http-echo:0.2.3 |
| PORT | Porta do container | 5678 |
| REPLICAS | Número de réplicas | 2 |
| ARGS | Argumentos do container | ["-text=hello"] |
| CPU_LIMIT | Limite de CPU | 100m |
| MEM_LIMIT | Limite de memória | 128Mi |
| LIVENESS_PATH | Path do liveness | / |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: Engenheiro de infra senior em Kubernetes.

Contexto: k3s single-node, namespace ai-iac-lab.

Crie manifests Kubernetes:
- Nome: notification-api
- Imagem: hashicorp/http-echo:0.2.3
- Porta: 5678
- Replicas: 2
- Args: [\"-text=notification-api running\"]
- Limits: CPU=100m, memory=128Mi
- Liveness: GET / porta 5678
- Labels: app=notification-api, version=0.2.3

Restrições: YAML válido, resource limits, probes, sem latest.
Formato: deployment.yaml + service.yaml separados por ---"
```

## Validação

```bash
kubectl apply -f output.yaml --dry-run=server -n ai-iac-lab
kubectl apply -f output.yaml -n ai-iac-lab
kubectl get pods -n ai-iac-lab -l app=notification-api
```
