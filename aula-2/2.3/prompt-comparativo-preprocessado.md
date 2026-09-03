# Comparativo: Análise de logs — bruto vs. pré-processado

## Cenário
Serviço respondendo lento, precisamos identificar a causa nos logs.

---

## ❌ Colar log bruto (500 linhas)

```
analisa esses logs pra mim:

[cola 500 linhas de log com INFO, DEBUG, WARN, ERROR misturados]
```

### Problemas:
- Estoura ou dilui a janela de contexto
- Modelo perde foco com ruído (linhas INFO/DEBUG)
- Análise superficial

---

## ✅ Pré-processar + prompt focado

### Passo 1: Filtrar antes de enviar
```bash
kubectl logs order-api -n ai-iac-lab --since=5m | grep -i "error\|warn\|slow\|timeout" | tail -30
```

### Passo 2: Prompt estruturado
```
Analise os logs abaixo de um serviço "order-api" rodando no k3s.
O serviço começou a responder lento há ~5 minutos.

Identifique:
1. Padrões repetidos
2. Timestamp de início do problema
3. Possíveis causas raiz

Formato: lista ordenada por probabilidade, com evidência do log.

Logs (filtrados por error/warn/timeout, últimos 5 min):
2024-03-15T10:20:03Z WARN  db query took 3200ms (threshold: 500ms)
2024-03-15T10:20:05Z WARN  db query took 4100ms (threshold: 500ms)
2024-03-15T10:20:08Z ERROR timeout waiting for db connection (pool exhausted)
2024-03-15T10:20:10Z WARN  db query took 5800ms (threshold: 500ms)
2024-03-15T10:20:12Z ERROR timeout waiting for db connection (pool exhausted)
2024-03-15T10:20:15Z ERROR request timeout: GET /orders (client disconnected after 30s)
2024-03-15T10:20:18Z ERROR timeout waiting for db connection (pool exhausted)
```

### Por que funciona:
- Log filtrado = modelo foca no relevante
- Contexto temporal claro
- Pede formato específico (lista com evidência)
- Modelo consegue identificar padrão: pool de conexões esgotado → queries lentas → timeouts
