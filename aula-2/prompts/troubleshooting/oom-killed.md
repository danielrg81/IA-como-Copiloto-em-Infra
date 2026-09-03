# Prompt: OOMKilled Diagnosis

## Descrição
Diagnosticar pods terminados por OOMKilled — identificar causa do consumo excessivo de memória.

## Template

```
Papel: Você é um SRE senior especializado em troubleshooting de memória em Kubernetes.

Ambiente: k3s single-node, namespace {{NAMESPACE}}
Sintoma: pod "{{POD_NAME}}" foi terminado com razão OOMKilled
Resource limits configurados: memory={{MEMORY_LIMIT}}
Último restart: {{LAST_RESTART}}

Logs antes do OOM (últimos 3 minutos):
{{LOGS}}

Informações adicionais:
- Tipo de workload: {{WORKLOAD_TYPE}}
- Linguagem/runtime: {{RUNTIME}}
- Padrão de uso: {{USAGE_PATTERN}}

O que já tentei:
- {{ATTEMPTED_FIXES}}

Pergunta: 
1. O que está causando o consumo excessivo de memória?
2. Devo aumentar o limit ou corrigir o código/configuração?
3. Quais métricas devo monitorar para prevenir recorrência?

Formato: análise em bullet points + recomendação final.
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| NAMESPACE | Namespace | ai-iac-lab |
| POD_NAME | Nome do pod | email-worker |
| MEMORY_LIMIT | Limit de memória | 128Mi |
| LAST_RESTART | Quando reiniciou | 2 min atrás |
| LOGS | Logs pré-OOM | ver logs-simulados/oom-killed.log |
| WORKLOAD_TYPE | Tipo de carga | worker processando fila |
| RUNTIME | Linguagem | Node.js 18 |
| USAGE_PATTERN | Padrão | processa jobs em batch |
| ATTEMPTED_FIXES | Tentativas | aumentar limit para 256Mi (voltou a crashar) |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: SRE senior especializado em troubleshooting de memória em Kubernetes.

Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod email-worker terminado com OOMKilled
Resource limits: memory=128Mi
Último restart: 2 min atrás

Logs antes do OOM:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/oom-killed.log)

Informações:
- Workload: worker processando fila de emails
- Runtime: Node.js 18
- Padrão: processa jobs em batch, cada job pode ter N anexos

O que já tentei:
- Aumentar limit para 256Mi (voltou a crashar após 5 min)

1. O que está causando o consumo excessivo?
2. Devo aumentar limit ou corrigir configuração?
3. Quais métricas monitorar?

Formato: análise em bullet points + recomendação final."
```
