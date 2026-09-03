# Aula 3 — Labs de Helm com k3s

## Labs

| Lab | O que faz | Conceitos |
|-----|-----------|-----------|
| 04-helm-basic | Nginx com Deployment + Service | Chart.yaml, values, templates básicos |
| 05-helm-conditionals | Ingress e HPA opcionais | `{{ if }}`, flags no values.yaml |
| 06-helm-helpers | Multi-container com loop | `_helpers.tpl`, `{{ range }}`, `nindent`, `toYaml` |

## Como usar

```bash
# Validar sem instalar
helm template meu-app ./04-helm-basic

# Lint
helm lint ./04-helm-basic

# Instalar no k3s
helm install meu-app ./04-helm-basic -n ai-iac-lab

# Upgrade com valores diferentes
helm upgrade meu-app ./04-helm-basic --set replicaCount=3

# Desinstalar
helm uninstall meu-app -n ai-iac-lab
```

## Exercícios com IA

1. Peça para a IA gerar um chart a partir de specs em linguagem natural
2. Peça para adicionar liveness/readiness probes ao chart 04
3. Peça para a IA explicar o que `nindent` e `toYaml` fazem no chart 06
4. Peça code review: "esse chart tem problemas de segurança?"
