# Prompt: Anomalia em Métricas

## Descrição
Analisar métricas para identificar anomalias e sugerir ações.

## Template

```
Papel: Você é um SRE sênior analisando métricas de um serviço em produção.

Contexto: Serviço "{SERVICE_NAME}" no k3s, namespace {NAMESPACE}.
Baseline normal: {BASELINE}

Métricas atuais:
{METRICAS}

Instrução:
1. Identifique quais métricas estão fora do padrão
2. Correlacione com possíveis causas
3. Sugira ações imediatas e investigações adicionais

Formato: tabela com métrica | valor atual | baseline | status (ok/warn/critical)
Seguida de recomendações ordenadas por urgência.
```

## Variáveis
| Variável | Exemplo |
|----------|---------|
| BASELINE | CPU ~20%, memory ~60%, latency p99 <200ms |
| METRICAS | output de `kubectl top pod` ou Prometheus |

## Como coletar métricas no k3s

```bash
# CPU e memória dos pods
kubectl top pods -n ai-iac-lab

# Todos os pods com uso alto
kubectl top pods -A --sort-by=cpu | head -10
```
