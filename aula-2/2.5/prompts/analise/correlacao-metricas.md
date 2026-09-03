# Prompt: Correlação de Métricas e Eventos

## Descrição
Correlacionar métricas, logs e eventos para identificar causa raiz em cenários multi-sinal.

## Template

```
Papel: Você é um SRE senior fazendo análise de incidente com múltiplas fontes de dados.

Contexto:
- Ambiente: k3s single-node
- Serviço afetado: {{SERVICE_NAME}}
- Início do problema: {{START_TIME}}
- Duração: {{DURATION}}

Dados disponíveis:

MÉTRICAS:
{{METRICS}}

LOGS (filtrados):
{{LOGS}}

EVENTOS KUBERNETES:
{{EVENTS}}

DEPLOYS RECENTES:
{{DEPLOYS}}

Correlacione os dados acima e responda:
1. Qual evento iniciou a cadeia de problemas?
2. Qual a relação causal entre os sinais?
3. O problema é de aplicação, infraestrutura ou configuração?
4. Qual a ação corretiva imediata e qual a preventiva?

Formato: diagrama de causa-efeito em texto + ações priorizadas.
```

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: SRE senior fazendo análise de incidente multi-sinal.

Contexto:
- Ambiente: k3s single-node
- Serviço: order-api
- Início: 10:18
- Duração: 7 minutos

MÉTRICAS:
- CPU: 15% → 45% às 10:18
- Memory: 80Mi → 120Mi (limit 128Mi)
- Request latency p99: 50ms → 5200ms
- Error rate: 0% → 35%

LOGS:
- 10:18 WARN db query took 1200ms
- 10:19 ERROR pool exhausted (10/10)
- 10:19 ERROR request timeout

EVENTOS K8S:
- 10:19:25 Liveness probe failed
- 10:19:25 Container restarted

DEPLOYS:
- 10:15 helm upgrade order-api (values: DB_POOL_SIZE 50→10)

Correlacione e responda:
1. Qual evento iniciou o problema?
2. Relação causal entre sinais?
3. Aplicação, infra ou config?
4. Ação corretiva + preventiva?"
```
