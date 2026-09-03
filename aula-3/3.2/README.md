# 3.2 — Refatorando código Terraform com ajuda de IA

## Objetivo
Usar IA para analisar código Terraform "legado" e refatorar incrementalmente sem quebrar recursos existentes no k3s.

## Pré-requisitos
```bash
# Lab 3.1 concluído (ou ao menos terraform instalado + k3s rodando)
terraform version
kubectl get nodes
```

---

## Roteiro de Comandos

### Passo 1 — Aplicar o código legado (criar o state)
```bash
cd ~/ai-iac-labs/aula-3/3.2

# Usar apenas o legacy.tf (copiar para main.tf de trabalho)
cp legacy.tf main.tf

terraform init
terraform apply -auto-approve

# Confirmar que está rodando
kubectl get all -n legacy-app
```

> **Ponto de observação:** O código funciona, mas tem vários problemas. Quantos você consegue identificar antes de pedir ajuda à IA?

### Passo 2 — Pedir análise à IA
```bash
kiro chat < prompt-analise.md
```

> **Exercício:** Compare a resposta da IA com sua própria análise. A IA pegou algo que você não viu?

### Passo 3 — Refactoring #1: Fixar a imagem (update in-place)
Trocar `nginx:latest` por `nginx:1.25-alpine` no deployment:
```bash
# Editar main.tf — trocar a imagem
# Depois validar:
terraform plan
```

> **O que observar no plan:** deve mostrar `~ update in-place` no deployment, NÃO `- destroy`.

```bash
terraform apply -auto-approve
kubectl get pods -n legacy-app -o jsonpath='{.items[*].spec.containers[*].image}'
```

### Passo 4 — Refactoring #2: Adicionar resource limits (update in-place)
Adicionar bloco `resources {}` no container:
```hcl
resources {
  limits = {
    cpu    = "100m"
    memory = "128Mi"
  }
}
```

```bash
terraform plan    # deve ser update in-place
terraform apply -auto-approve
kubectl describe deployment my-app -n legacy-app | grep -A4 Limits
```

### Passo 5 — Refactoring #3: Extrair secret (novo resource)
Usar o prompt incremental para pedir ajuda à IA:
```bash
kiro chat < prompt-refactor-incremental.md
```

Aplicar a sugestão da IA e validar:
```bash
terraform plan    # deve mostrar: 1 to add, 1 to change, 0 to destroy
terraform apply -auto-approve
kubectl get secret -n legacy-app
```

### Passo 6 — Refactoring #4: Extrair variáveis
Mover valores hardcoded para `variables.tf`:
```bash
# Copiar o variables.tf de referência
# Atualizar main.tf para usar var.xxx em vez de strings literais
terraform plan    # deve ser 0 changes (valores iguais aos defaults)
terraform apply -auto-approve
```

> **Ponto-chave:** Quando os defaults das variáveis têm o mesmo valor que estava hardcoded, o plan mostra "No changes" — refactoring puro.

### Passo 7 — Refactoring #5: Renomear resources com moved blocks
Se quiser renomear `kubernetes_namespace.ns` para `kubernetes_namespace.app`:
```bash
# Adicionar moved block (ver moved.tf de referência)
# Renomear o resource no código
terraform plan    # deve mostrar "moved" e 0 destroys
terraform apply -auto-approve
```

### Passo 8 — Validação final
```bash
# Comparar com a versão refatorada de referência
diff <(terraform state list | sort) <(echo "kubernetes_config_map.app
kubernetes_deployment.app
kubernetes_namespace.app
kubernetes_secret.app
kubernetes_service.app" | sort)

# Verificar que tudo continua rodando
kubectl get all -n legacy-app
curl -s $(kubectl get svc my-app -n legacy-app -o jsonpath='{.spec.clusterIP}')
```

### Passo 9 — Cleanup
```bash
terraform destroy -auto-approve
kubectl get ns legacy-app  # deve retornar: not found
```

---

## Estrutura dos arquivos

```
3.2/
├── README.md                    ← Este arquivo (roteiro)
├── legacy.tf                    ← Código "legado" inicial (propositalmente ruim)
├── refactored.tf                ← Versão final refatorada (referência)
├── variables.tf                 ← Variáveis da versão refatorada
├── outputs.tf                   ← Outputs da versão refatorada
├── moved.tf                     ← Moved blocks para renomear resources
├── prompt-analise.md            ← Prompt para análise do código legado
└── prompt-refactor-incremental.md ← Prompt para refactoring incremental
```

## Problemas intencionais no legacy.tf

| # | Problema | Severidade | Tipo de fix |
|---|----------|-----------|-------------|
| 1 | `nginx:latest` — tag instável | Alta | update in-place |
| 2 | `DB_PASSWORD` em plain text | Alta | novo resource (Secret) |
| 3 | Sem resource limits | Alta | update in-place |
| 4 | Sem liveness/readiness probes | Média | update in-place |
| 5 | Namespace hardcoded em string | Média | refactoring puro |
| 6 | Sem labels (managed-by, env) | Baixa | update in-place |
| 7 | Sem variáveis (tudo hardcoded) | Baixa | refactoring puro |
| 8 | Sem outputs | Baixa | adicionar (sem impacto) |
| 9 | 3 réplicas excessivas para lab | Baixa | update in-place |

## Pontos-chave para discussão

1. **terraform plan é o juiz final** — a IA sugere, o plan confirma se é seguro
2. **Incrementalidade** — uma mudança por vez permite isolar problemas
3. **update in-place vs destroy+recreate** — saber a diferença evita downtime
4. **moved blocks** — permitem renomear resources sem destruir infra
5. **Refactoring puro** — mudanças que não alteram o state (extrair variáveis com mesmos valores)
6. **IA não conhece seu state** — sempre validar sugestões com `terraform plan`
