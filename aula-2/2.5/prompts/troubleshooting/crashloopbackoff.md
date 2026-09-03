# Prompt: CrashLoopBackOff Diagnosis

## Descrição
Diagnosticar pods em CrashLoopBackOff com contexto estruturado para obter causa raiz acionável.

## Template

```
Papel: Você é um SRE senior especializado em Kubernetes.

Ambiente: k3s single-node, namespace {{NAMESPACE}}
Sintoma: pod "{{POD_NAME}}" em CrashLoopBackOff há {{DURATION}}
Restarts: {{RESTART_COUNT}}

Logs relevantes (últimos 2 minutos):
{{LOGS}}

Describe pod (relevante):
- Image: {{IMAGE}}
- Env: {{ENV_VARS}}
- Init containers: {{INIT_CONTAINERS}}

O que já tentei:
- {{ATTEMPTED_FIXES}}

Pergunta: qual a causa raiz mais provável e qual o próximo passo concreto para resolver?
Formato: diagnóstico em 1 parágrafo + 3 passos de ação ordenados por prioridade.
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| NAMESPACE | Namespace do pod | ai-iac-lab |
| POD_NAME | Nome do pod | order-api |
| DURATION | Tempo no estado | 10 minutos |
| RESTART_COUNT | Número de restarts | 5 |
| LOGS | Logs filtrados | ver logs-simulados/crashloop.log |
| IMAGE | Imagem do container | order-api:v1.2.0 |
| ENV_VARS | Variáveis de ambiente relevantes | DB_HOST=localhost |
| INIT_CONTAINERS | Init containers se houver | nenhum |
| ATTEMPTED_FIXES | O que já foi tentado | restart do pod |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: Você é um SRE senior especializado em Kubernetes.

Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod order-api em CrashLoopBackOff há 10 minutos
Restarts: 5

Logs relevantes:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Describe pod:
- Image: order-api:v1.2.0
- Env: DB_HOST=localhost, DB_PORT=5432
- Init containers: nenhum

O que já tentei:
- Restart do pod
- Verificar se há Service postgres no namespace (não existe)

Qual a causa raiz mais provável e qual o próximo passo concreto?
Formato: diagnóstico em 1 parágrafo + 3 passos de ação."
```
