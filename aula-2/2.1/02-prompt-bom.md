# Prompt Bom — Com estrutura completa

## Prompt

```
Papel: Você é um engenheiro DevOps senior que segue boas práticas de segurança e observabilidade.

Contexto: Estou criando um deployment para o serviço order-api no namespace ai-iac-lab.
Cluster k3s local, ambiente de desenvolvimento.
A imagem é order-api:1.2.0 no registry local.

Instrução: Gere um Deployment Kubernetes para esse serviço.

Restrições:
- Porta 8080
- 2 réplicas
- Resource requests e limits definidos (cpu: 100m/200m, memory: 128Mi/256Mi)
- Liveness probe em /healthz (HTTP, porta 8080)
- Readiness probe em /ready (HTTP, porta 8080)
- Não usar latest
- Labels padrão: app, version, team=platform

Formato de saída: YAML válido, sem explicações, apenas o manifest pronto para kubectl apply.
```

## Por que é bom

| Elemento | Presente | Efeito |
|---|---|---|
| Papel | ✅ | IA assume postura de senior com boas práticas |
| Contexto | ✅ | Resposta específica pro ambiente |
| Instrução | ✅ | Objetivo claro e direto |
| Restrições | ✅ | Elimina ambiguidade |
| Formato | ✅ | Output pronto para usar |

## Execute e compare

```bash
kiro chat "Papel: Você é um engenheiro DevOps senior que segue boas práticas de segurança e observabilidade.

Contexto: Estou criando um deployment para o serviço order-api no namespace ai-iac-lab.
Cluster k3s local, ambiente de desenvolvimento.
A imagem é order-api:1.2.0 no registry local.

Instrução: Gere um Deployment Kubernetes para esse serviço.

Restrições:
- Porta 8080
- 2 réplicas
- Resource requests e limits definidos (cpu: 100m/200m, memory: 128Mi/256Mi)
- Liveness probe em /healthz (HTTP, porta 8080)
- Readiness probe em /ready (HTTP, porta 8080)
- Não usar latest
- Labels padrão: app, version, team=platform

Formato de saída: YAML válido, sem explicações, apenas o manifest pronto para kubectl apply."
```

## Validar o output

```bash
# Salvar resposta em deployment.yaml e testar:
kubectl apply --dry-run=client -f deployment.yaml
```
