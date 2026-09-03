# 4.4 — Blast radius e guardrails: protegendo infra de ações automáticas

## Contexto

Terça-feira, 14h. O time configurou um agente de IA que monitora alertas de disco e faz "auto-remediação". Um alerta de `disk usage > 80%` dispara no namespace `production`. O agente analisa: "preciso liberar espaço". Decide executar: `kubectl delete pvc --all -n production`.

Os Persistent Volume Claims de 3 serviços são destruídos. Dados de clientes perdidos. Restauração de backup leva 6 horas. Post-mortem: o agente fez exatamente o que a lógica mandava — "liberar disco". Mas ninguém definiu o **limite do que ele poderia fazer**. Ninguém calculou o **blast radius** daquela ação.

Agora compare com outro cenário: mesmo alerta, mesmo agente, mas com guardrails. O agente analisa o disco, identifica logs antigos, propõe `kubectl delete pod` para recriar com log rotation. Antes de executar, o script exige aprovação humana. O operador vê a proposta, aprova, o agente executa. Problema resolvido. Zero dano.

A diferença? Camadas de proteção entre "decidir" e "executar".

## Problema

Quanto mais autonomia a IA tem, maior o potencial de dano. Um agente com `kubectl delete` num namespace de produção tem o mesmo blast radius que um engenheiro com acesso root — mas sem o julgamento humano de "isso é realmente o que eu quero fazer?".

Precisamos de proteções proporcionais ao risco. Ações read-only não precisam de gate. Delete em produção precisa de múltiplas aprovações.

## Teoria

### O que é Blast Radius

**Blast radius** = o escopo máximo de dano que uma ação pode causar se der errado.

| Ação | Blast Radius | Se der errado... |
|------|-------------|-----------------|
| `kubectl get pods` | Nenhum | Nada acontece (read-only) |
| `helm template` | Nenhum | Gera YAML local, nada muda |
| `terraform plan` | Nenhum | Calcula mas não aplica |
| `kubectl apply -n test` | Namespace test | Pods de teste quebram |
| `helm upgrade -n staging` | Namespace staging | Serviço em staging indisponível |
| `terraform apply` (prod) | Infra de produção | Serviços fora, possível perda de dados |
| `kubectl delete ns prod` | Namespace inteiro | Todos os workloads destruídos |
| `kubectl delete pvc` (prod) | Dados permanentes | Perda irreversível |

**Regra:** Blast radius determina quantas camadas de proteção são necessárias.

---

### As 5 camadas de guardrails

```
        Mais proteção
              ↑
┌─────────────────────────────────────┐
│ 5. ROLLBACK AUTOMÁTICO              │  Se health falhar → volta pra versão anterior
│    helm rollback, terraform revert  │
├─────────────────────────────────────┤
│ 4. MONITORAMENTO PÓS-AÇÃO          │  Verificar health depois de aplicar
│    kubectl wait, health checks      │
├─────────────────────────────────────┤
│ 3. APROVAÇÃO HUMANA                 │  Humano vê o plan e decide
│    read -p, PR approval, Slack bot  │
├─────────────────────────────────────┤
│ 2. DRY-RUN OBRIGATÓRIO             │  Mostrar o que VAI acontecer
│    terraform plan, --dry-run=server │
├─────────────────────────────────────┤
│ 1. SANDBOXING                       │  Ambiente isolado onde errar é seguro
│    k3s local, namespace de teste    │
└─────────────────────────────────────┘
              ↓
        Menos proteção
```

---

### Camada 1: Sandboxing — "errar aqui é grátis"

O k3s que usamos neste curso é um sandbox. Podemos destruir tudo e recriar em minutos. Isso é intencional — o ambiente de teste existe para absorver erros.

**Exemplo prático:**

```
Produção (EKS):
  - 200 pods, dados de clientes, SLA 99.9%
  - Blast radius de erro: alto
  - Custo de downtime: $$$

Sandbox (k3s local):
  - 5 pods de teste, dados fictícios, sem SLA
  - Blast radius de erro: zero
  - Custo de downtime: 0
```

**Regra:** Todo código gerado por IA é testado primeiro no sandbox. SEMPRE.

---

### Camada 2: Dry-run — "me mostra antes de fazer"

Dry-run é a camada mais barata e eficaz. Custo zero, detecta a maioria dos problemas:

```bash
# Terraform: mostra o que será criado/modificado/destruído
terraform plan -out=tfplan

# Kubernetes: valida contra a API real sem aplicar
kubectl apply -f manifest.yaml --dry-run=server

# Helm: renderiza e valida sem instalar
helm install app ./chart --dry-run
helm upgrade app ./chart --dry-run
```

**O que o dry-run pega que o lint não pega:**
- APIs deprecated (dry-run=server valida contra o cluster real)
- Conflitos com resources existentes
- Permissões insuficientes da ServiceAccount
- ResourceQuota que seria excedido

---

### Camada 3: Aprovação humana — "você confirma?"

O agente propõe. O humano decide. Nunca o contrário.

**Padrão em script:**
```bash
echo "O agente propõe: helm upgrade order-api --set replicas=5"
echo "Blast radius: namespace ai-iac-lab (2 pods afetados)"
read -p "Aprovar? (s/n): " resposta
```

**Padrão em pipeline (CI):**
- PR com terraform plan no comentário
- Aprovação de 1 pessoa para staging
- Aprovação de 2 pessoas para produção

**Padrão em chat-ops:**
- Agente posta proposta no Slack
- Reação com ✅ = aprovado
- Reação com ❌ = bloqueado

---

### Camada 4: Monitoramento pós-ação — "deu certo?"

Aplicou? Verifica. Sempre.

```bash
# Após kubectl apply
kubectl wait --for=condition=ready pod -l app=order-api --timeout=60s

# Após helm upgrade
kubectl get pods -n ai-iac-lab -w  # watch até estabilizar

# Após terraform apply
# Verificar outputs, testar endpoints
```

Se o health check falha → aciona camada 5.

---

### Camada 5: Rollback automático — "desfaz, rápido"

Se a camada 4 detecta problema, rollback imediato sem esperar humano:

```bash
# Helm: volta para a revisão anterior
helm rollback order-api 0 -n ai-iac-lab

# Kubernetes: rollback do deployment
kubectl rollout undo deployment/order-api -n ai-iac-lab

# Terraform: revert do commit + apply
git revert HEAD && terraform apply -auto-approve
```

**Quando rollback automático é aceitável:**
- Health check definido e confiável
- Versão anterior comprovadamente estável
- Blast radius do rollback ≤ blast radius do problema

---

### Menor privilégio para agentes

Mesmo princípio de RBAC que aplicamos a ServiceAccounts humanas:

| Se o agente precisa... | Dê apenas... | NUNCA dê... |
|------------------------|-------------|-------------|
| Investigar incidente | `get`, `list` em pods/logs | `delete`, `create` |
| Fazer deploy | `create`, `update` deployments | `delete namespace` |
| Escalar réplicas | `patch` deployments/scale | `delete pvc` |
| Auto-remediar (limitado) | `delete pod` (restart) | `delete pvc`, `delete ns` |

**Implementação:** ServiceAccount dedicada para o agente, com Role mínima. Se o agente tentar algo além da permissão, o RBAC bloqueia antes que o LLM execute uma decisão errada.

---

## Exemplo integrado: Pipeline com todas as camadas

```
1. Desenvolvedor pede ao agente: "deploy payment-api v2.1 no staging"

2. [CAMADA 1 - SANDBOX] Agente verifica: namespace "staging" ✓ (não é production)

3. [CAMADA 2 - DRY-RUN] Agente executa:
   helm upgrade payment-api ./chart --dry-run -n staging
   Resultado: "1 deployment updated, 0 destroyed"

4. [CAMADA 3 - APROVAÇÃO] Agente mostra o resultado do dry-run:
   "Vou atualizar image de v2.0 para v2.1. 2 pods serão recriados.
    Blast radius: namespace staging apenas.
    Aprovar?"
   Humano: "Sim"

5. [EXECUÇÃO] Agente aplica:
   helm upgrade payment-api ./chart -n staging

6. [CAMADA 4 - MONITORAMENTO] Agente verifica:
   kubectl wait --for=condition=ready -l app=payment-api --timeout=60s
   "2/2 pods Ready ✓"

7. [CAMADA 5 - ROLLBACK] (não acionada, tudo ok)
   Se tivesse falhado: helm rollback payment-api -n staging
```

---

## Anti-padrões (o que NÃO fazer)

| Anti-padrão | Por que é perigoso | O que fazer em vez |
|-------------|-------------------|-------------------|
| `terraform apply -auto-approve` em produção | Zero aprovação humana | Sempre `plan` + review + `apply` |
| Agente com ClusterAdmin | Blast radius = cluster inteiro | Role mínima por namespace |
| Pular dry-run "porque estou com pressa" | O dia que der errado, vai ser o dia da pressa | Dry-run é 5 segundos. Incidente é 5 horas. |
| Rollback manual (depende de alguém detectar) | MTTR alto, horário fora do expediente | Automatizar com health check + timeout |
| "O código foi gerado por IA, não é minha responsabilidade" | Responsabilidade é de quem aprova/aplica | Quem faz merge, é dono |

---

## Pontos-chave

1. **Blast radius determina proteção** — Não trate todas as ações iguais. Read-only é livre. Delete em prod precisa de 2 aprovações.
2. **Dry-run é a melhor relação custo/benefício** — Zero custo, 5 segundos, pega 80% dos problemas. Não existe motivo para pular.
3. **RBAC é o guardrail definitivo** — Mesmo que a IA "decida" fazer algo perigoso, sem permissão não executa. É a última linha de defesa.
4. **Rollback precisa ser automático** — Se depende de humano detectar problema e agir manualmente, o MTTR é inaceitável.
5. **Sandbox existe para ser destruído** — É o ambiente de absorção de erros. Use-o. Destrua-o. Recrie-o. Para isso ele serve.
