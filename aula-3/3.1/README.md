# 3.1 — Gerando código Terraform com assistentes de IA

## Objetivo
Usar IA para gerar código Terraform (provider Kubernetes) e validar no k3s local.

## Pré-requisitos
```bash
# Terraform instalado
terraform version

# k3s rodando
kubectl get nodes

# kubeconfig acessível
cat ~/.kube/config | head -5
```

---

## Roteiro de Comandos

### Passo 1 — Preparar o diretório
```bash
cd ~/ai-iac-labs/aula-3/3.1
ls -la
```

### Passo 2 — Enviar o prompt de geração para a IA
Copie o conteúdo de `prompt-geracao.md` e envie para o Kiro CLI:
```bash
kiro chat < prompt-geracao.md
```
Ou cole manualmente no terminal interativo.

> **Ponto de observação:** Compare o output da IA com os arquivos `main.tf`, `variables.tf` e `outputs.tf` que já estão aqui como referência.

### Passo 3 — Inicializar e validar
```bash
# Inicializar o provider
terraform init

# Validar sintaxe
terraform validate

# Ver o plano de execução (SEM aplicar)
terraform plan
```

> **Checklist de revisão do plan:**
> - Quantos resources serão criados?
> - Os nomes estão corretos?
> - Limits de CPU/memória fazem sentido?
> - O namespace é o esperado?

### Passo 4 — Aplicar no k3s
```bash
# Aplicar
terraform apply -auto-approve

# Validar com kubectl
kubectl get all -n app-production
kubectl get resourcequota -n app-production
kubectl get configmap -n app-production
```

### Passo 5 — Iterar: pedir RBAC à IA
Envie o prompt de `prompt-rbac.md`:
```bash
kiro chat < prompt-rbac.md
```

Depois de obter o output, compare com `rbac.tf` e aplique:
```bash
terraform validate
terraform plan
terraform apply -auto-approve

# Validar
kubectl get serviceaccount -n app-production
kubectl get role -n app-production
kubectl get rolebinding -n app-production
```

### Passo 6 — Demo extra: converter YAML → Terraform
Envie o prompt de `prompt-converter-yaml.md`:
```bash
kiro chat < prompt-converter-yaml.md
```

> **Ponto de discussão:** O output manteve a funcionalidade? Usou variáveis? O que você ajustaria?

### Passo 7 — Cleanup
```bash
terraform destroy -auto-approve

# Confirmar
kubectl get ns app-production
# Deve retornar: not found
```

---

## Estrutura dos arquivos

```
3.1/
├── README.md              ← Este arquivo (roteiro)
├── main.tf                ← Código Terraform de referência
├── variables.tf           ← Variáveis parametrizadas
├── outputs.tf             ← Outputs úteis
├── rbac.tf                ← RBAC (gerado na iteração, passo 5)
├── prompt-geracao.md      ← Prompt para gerar o código base
├── prompt-rbac.md         ← Prompt para iterar (adicionar RBAC)
└── prompt-converter-yaml.md ← Prompt para converter YAML existente
```

## Pontos-chave para discussão

1. **IA como primeiro rascunho** — o output precisa de revisão humana antes do `apply`
2. **terraform plan é obrigatório** — nunca aplicar sem revisar o plano
3. **Variáveis** — código parametrizado é mais reutilizável que hardcoded
4. **Iteração** — começar simples e pedir incrementos funciona melhor que pedir tudo de uma vez
5. **Terraform vs kubectl/Helm** — Terraform gerencia state, ideal para recursos de plataforma (namespaces, quotas, RBAC); Helm é melhor para aplicações com ciclos de release frequentes
