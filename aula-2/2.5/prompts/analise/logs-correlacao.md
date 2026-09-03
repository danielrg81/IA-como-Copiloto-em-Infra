# Prompt: Correlação de Logs

## Descrição
Analisar logs filtrados para identificar causa raiz de degradação.

## Template

```
Papel: Você é um SRE sênior analisando um incidente.

Contexto: Serviço "{SERVICE_NAME}" rodando no k3s, namespace {NAMESPACE}.
O serviço começou a {SINTOMA} há ~{DURAÇÃO}.

Instrução: Analise os logs abaixo e identifique:
1. Padrões repetidos
2. Timestamp de início do problema
3. Cadeia de causa e efeito
4. Causa raiz mais provável

Formato: lista ordenada por probabilidade, com evidência do log.

Logs (filtrados por {FILTRO}, últimos {JANELA}):
{LOGS}
```

## Como pré-processar os logs

```bash
# Filtrar por severidade
kubectl logs {POD} --since=5m | grep -i "error\|warn\|timeout\|slow"

# Filtrar por janela temporal
kubectl logs {POD} --since-time="2024-03-15T10:15:00Z"

# Remover ruído (linhas de health check)
kubectl logs {POD} --since=5m | grep -v "GET /healthz"
```

## Exemplo de uso
Ver `../../logs-simulados/slow-response.log`
