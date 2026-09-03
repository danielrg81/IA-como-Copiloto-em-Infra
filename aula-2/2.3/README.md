# Aula 2.3 — Prompts para Análise de Logs e Métricas

## Arquivos

```
2.3/
├── README.md                          # Este arquivo
├── prompt-anti-exemplo.md             # Prompt ruim (o que NÃO fazer)
├── prompt-logs-performance.md         # Template: análise de latência
├── prompt-logs-correlacao.md          # Template: correlação de eventos
├── prompt-comparativo-preprocessado.md # Comparativo: bruto vs. filtrado
├── logs-simulados/
│   ├── slow-response.log             # Cenário: pool exhaustion
│   └── oom-killed.log                # Cenário: memory leak → OOM
└── order-api-slow.yaml               # Deploy que gera logs ao vivo no k3s
```

## Como usar na aula

1. Subir o cenário: `kubectl apply -f order-api-slow.yaml`
2. Mostrar abordagem ruim: `kubectl logs -n ai-iac-lab deployment/order-api --tail=30`
3. Mostrar abordagem boa: `kubectl logs -n ai-iac-lab deployment/order-api --since=2m | grep -iE "error|warn|timeout" | tail -15`
4. Usar o prompt de `prompt-logs-performance.md` com os logs filtrados
