# Comparativo: Troubleshooting sem estrutura vs. com estrutura

## Cenário
Um pod está em CrashLoopBackOff e precisamos diagnosticar.

---

##  Sem estrutura

```
meu pod ta crashando, olha os logs:

Error: connection refused localhost:5432
Error: connection refused localhost:5432
Error: connection refused localhost:5432
```

### Output típico:
"Verifique se o banco de dados está rodando" — genérico e óbvio.

---

##  Com estrutura

```
Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod "order-api" em CrashLoopBackOff há 10 minutos
Restarts: 5

Logs relevantes (últimos 2 minutos):
2024-03-15T10:23:01Z ERROR connection refused localhost:5432
2024-03-15T10:23:01Z INFO retrying in 5s...
2024-03-15T10:23:06Z ERROR connection refused localhost:5432
2024-03-15T10:23:06Z FATAL max retries exceeded, shutting down

Describe pod (relevante):
- Image: order-api:v1.2.0
- Env: DB_HOST=localhost, DB_PORT=5432
- No init containers

O que já tentei:
- Restart do pod (voltou ao mesmo estado)
- Verificar se há um Service chamado "postgres" no namespace (não existe)

Pergunta: qual a causa raiz mais provável e qual o próximo passo concreto?
```

### Por que funciona:
- Delimita o ambiente (k3s, namespace)
- Mostra logs filtrados com timestamps
- Inclui informação do describe
- Diz o que já tentou (evita sugestões óbvias)
- Pede ação concreta, não explicação genérica
