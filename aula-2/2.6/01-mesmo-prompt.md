# Exercício 1 — Mesmo prompt, duas ferramentas

## Kiro CLI

```bash
kiro chat "Antes de responder, explique passo a passo como você vai resolver.
Depois, gere um Deployment Kubernetes para nginx com:
- 2 replicas
- Liveness probe em /healthz
- Resource limits: 256Mi RAM, 200m CPU
- Labels: app=web, env=production"
```

## Gemini CLI

```bash
gemini "Antes de responder, explique passo a passo como você vai resolver.
Depois, gere um Deployment Kubernetes para nginx com:
- 2 replicas
- Liveness probe em /healthz
- Resource limits: 256Mi RAM, 200m CPU
- Labels: app=web, env=production"
```

## Tabela de comparação

| Dimensão | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| Quantos passos de raciocínio mostrou? | | |
| Explicou antes ou depois do código? | | |
| O YAML funciona de primeira? | | |
| Adicionou algo que você não pediu? | | |
| Fez alguma pergunta de clarificação? | | |

## Validação

```bash
kubectl apply --dry-run=server -f output-kiro.yaml
kubectl apply --dry-run=server -f output-gemini.yaml
```
