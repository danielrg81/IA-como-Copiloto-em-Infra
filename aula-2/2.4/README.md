# Aula 2.4 — Prompts para Geração de Manifests e IaC

## Arquivos

```
2.4/
├── README.md                          # Este arquivo
├── prompt-anti-exemplo.md             # ❌ O que NÃO fazer
├── prompt-kubernetes-deployment.md    # ✅ Template: Deployment + Service
├── prompt-helm-chart.md              # ✅ Template: Helm chart completo
├── prompt-dockerfile.md              # ✅ Template: Dockerfile otimizado
├── prompt-runbook.md                 # ✅ Template: Runbook operacional
└── notification-api.yaml             # YAML de referência (output esperado)
```

## Como usar na aula

1. Mostrar prompt ruim: "cria um deployment kubernetes" → output genérico
2. Mostrar prompt estruturado de `prompt-kubernetes-deployment.md` → output preciso
3. Validar: `kubectl apply -f output.yaml --dry-run=server -n ai-iac-lab`
4. Demo Helm chart: usar `prompt-helm-chart.md` → `helm lint` + `helm template`
5. Mostrar `notification-api.yaml` como referência do que a IA deveria gerar
