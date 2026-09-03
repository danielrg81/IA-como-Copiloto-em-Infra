# Prompt: Geração de Helm Chart

## Descrição
Gerar um Helm chart completo e funcional com specs detalhadas para instalar no k3s.

## Template

```
Papel: Você é um engenheiro de infraestrutura senior especializado em Kubernetes e Helm.

Contexto: Cluster k3s single-node para desenvolvimento/lab. Namespace: {{NAMESPACE}}.

Instrução: Gere um Helm chart completo para o serviço abaixo.

Specs:
- Nome: {{SERVICE_NAME}}
- Imagem: {{IMAGE}}
- Porta: {{PORT}}
- Replicas: {{REPLICAS}}
- Resources:
  - requests: cpu={{CPU_REQUEST}}, memory={{MEM_REQUEST}}
  - limits: cpu={{CPU_LIMIT}}, memory={{MEM_LIMIT}}
- Probes:
  - liveness: {{LIVENESS_PATH}} (initialDelay: 10s, period: 10s)
  - readiness: {{READINESS_PATH}} (initialDelay: 5s, period: 5s)
- Ingress: {{INGRESS_HOST}} (se aplicável)
- Variáveis de ambiente: {{ENV_VARS}}
- HPA: {{HPA_CONFIG}} (se aplicável)

Restrições:
- Usar apiVersion compatível com k3s (apps/v1, networking.k8s.io/v1)
- Incluir labels padrão: app.kubernetes.io/name, app.kubernetes.io/version, app.kubernetes.io/managed-by
- SecurityContext: runAsNonRoot=true, readOnlyRootFilesystem=true
- Não usar latest como tag de imagem

Formato de saída: Estrutura completa do chart com cada arquivo separado:
1. Chart.yaml
2. values.yaml
3. templates/deployment.yaml
4. templates/service.yaml
5. templates/ingress.yaml (se aplicável)
6. templates/_helpers.tpl
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| NAMESPACE | Namespace alvo | ai-iac-lab |
| SERVICE_NAME | Nome do serviço | order-api |
| IMAGE | Imagem Docker | hashicorp/http-echo:0.2.3 |
| PORT | Porta do container | 5678 |
| REPLICAS | Número de réplicas | 2 |
| CPU_REQUEST/LIMIT | CPU | 50m / 100m |
| MEM_REQUEST/LIMIT | Memória | 64Mi / 128Mi |
| LIVENESS_PATH | Path do liveness | / |
| READINESS_PATH | Path do readiness | / |
| INGRESS_HOST | Hostname do ingress | order.local |
| ENV_VARS | Variáveis | DB_HOST=postgres, DB_PORT=5432 |
| HPA_CONFIG | Config do HPA | min=2, max=5, cpu=70% |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: Engenheiro de infra senior especializado em Kubernetes e Helm.

Contexto: Cluster k3s single-node, namespace ai-iac-lab.

Gere um Helm chart completo para:
- Nome: order-api
- Imagem: hashicorp/http-echo:0.2.3
- Porta: 5678
- Replicas: 2
- Resources: requests cpu=50m mem=64Mi, limits cpu=100m mem=128Mi
- Liveness: / (initialDelay 10s)
- Readiness: / (initialDelay 5s)
- Ingress: order.local
- Env: TEXT=order-api-running
- Args: [\"-text=order-api running\"]

Restrições:
- apiVersion compatível com k3s
- Labels padrão kubernetes
- SecurityContext: runAsNonRoot, readOnlyRootFilesystem
- Não usar latest

Formato: Chart.yaml + values.yaml + templates/ (cada arquivo separado)"
```

## Validação pós-geração

```bash
# Salvar output em diretório
mkdir -p /tmp/order-api-chart && cd /tmp/order-api-chart
# (colar arquivos gerados)

# Validar
helm lint .
helm template test .
helm install test . --namespace ai-iac-lab --dry-run

# Se tudo ok, instalar
helm install order-api . --namespace ai-iac-lab --create-namespace
kubectl get pods -n ai-iac-lab
```
