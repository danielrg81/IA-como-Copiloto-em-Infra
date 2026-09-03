# Exercício 3 — Diagnóstico sob pressão

Use o log simulado para testar capacidade de análise.

## Kiro CLI

```bash
kiro chat "Pod order-api em CrashLoopBackOff. Diagnostique:

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Quero: causa raiz + 3 ações priorizadas + comando exato para cada ação."
```

## Gemini CLI

```bash
gemini "Pod order-api em CrashLoopBackOff. Diagnostique:

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Quero: causa raiz + 3 ações priorizadas + comando exato para cada ação."
```

## Tabela de comparação

| Critério | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| Identificou a causa raiz correta? | | |
| Comandos sugeridos estão corretos? | | |
| Priorizou as ações de forma lógica? | | |
| Tempo até resposta útil | | |
