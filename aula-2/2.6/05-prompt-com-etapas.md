# Exercício 5 — Mesmo prompt com etapas narradas

## Objetivo
Pedir para a IA narrar seu raciocínio em etapas visíveis, tornando o "modelo mental" explícito.

## Kiro CLI

```bash
kiro chat "Para cada etapa, indique em qual fase você está:
[INTERPRETANDO] → o que entendi do pedido
[PLANEJANDO] → como vou resolver
[GERANDO] → escrevendo o código
[REVISANDO] → verificando erros

Agora, gere um Deployment Kubernetes para nginx com:
- 2 replicas
- Liveness probe em /healthz
- Resource limits: 256Mi RAM, 200m CPU
- Labels: app=web, env=production"
```

## Gemini CLI

```bash
gemini "Para cada etapa, indique em qual fase você está:
[INTERPRETANDO] → o que entendi do pedido
[PLANEJANDO] → como vou resolver
[GERANDO] → escrevendo o código
[REVISANDO] → verificando erros

Agora, gere um Deployment Kubernetes para nginx com:
- 2 replicas
- Liveness probe em /healthz
- Resource limits: 256Mi RAM, 200m CPU
- Labels: app=web, env=production"
```

## Tabela de comparação

| Dimensão | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| Usou todas as 4 etapas? | | |
| Qual etapa foi mais detalhada? | | |
| Encontrou erros na fase [REVISANDO]? | | |
| O output final melhorou vs. exercício 1? | | |
