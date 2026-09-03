# Prompt: Análise de Logs — Latência e Performance

## Descrição
Analisar logs de serviço com degradação de performance. Pré-processar antes de enviar.

## Workflow

### Passo 1: Filtrar logs relevantes
```bash
kubectl logs {{POD_NAME}} -n {{NAMESPACE}} --since=5m | grep -iE "error|warn|slow|timeout|latency" | tail -30
```

### Passo 2: Enviar com contexto

## Template

```
Papel: Você é um SRE analisando degradação de performance de um serviço.

Contexto:
- Serviço: {{SERVICE_NAME}} rodando no k3s
- Sintoma: {{SYMPTOM}}
- Início do problema: {{START_TIME}} (aproximado)
- Impacto: {{IMPACT}}

Analise os logs abaixo e identifique:
1. Padrões repetidos que indicam a causa
2. Timestamp exato de início do problema
3. Cadeia de eventos (o que causou o quê)
4. Causa raiz mais provável

Formato: 
- Timeline do incidente
- Causa raiz (1 frase)
- Evidência nos logs
- 3 ações para resolver, ordenadas por urgência

Logs (filtrados por error/warn/timeout, últimos 5 min):
{{LOGS}}
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| POD_NAME | Pod para coletar logs | order-api-7d4f8b-x2k |
| NAMESPACE | Namespace | ai-iac-lab |
| SERVICE_NAME | Nome do serviço | order-api |
| SYMPTOM | O que está acontecendo | respostas lentas (>5s) |
| START_TIME | Quando começou | ~10:18 |
| IMPACT | Quem é afetado | clientes recebendo timeout |
| LOGS | Logs filtrados | ver logs-simulados/slow-response.log |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: SRE analisando degradação de performance.

Contexto:
- Serviço: order-api rodando no k3s, namespace ai-iac-lab
- Sintoma: respostas lentas (>5s), alguns timeouts
- Início: ~10:18
- Impacto: clientes recebendo timeout em GET /orders

Analise os logs e identifique:
1. Padrões repetidos
2. Timestamp de início
3. Cadeia de eventos
4. Causa raiz

Formato: timeline + causa raiz + evidência + 3 ações urgentes

Logs filtrados:
$(kubectl logs -n ai-iac-lab deployment/order-api --since=2m | grep -iE 'error|warn|timeout' | tail -15)"
```
