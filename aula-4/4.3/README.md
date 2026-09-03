# 4.3 — Alucinações em IaC: quando a IA inventa e como detectar

## Contexto

Sexta-feira, 17h30. Deadline apertado. Você precisa entregar um módulo Terraform para provisionar a infra do novo serviço. Pede ao assistente de IA: "gere um módulo Terraform para o serviço payment-api com security group, deployment e service". O código vem em 10 segundos. Sintaticamente perfeito. `terraform validate` passa limpo. Você faz o PR correndo.

Na segunda-feira, o security engineer abre um chamado: "por que a porta 22 está aberta para 0.0.0.0/0 no security group do payment-api?". Você volta no código — lá está: `cidr_blocks = ["0.0.0.0/0"]`. A IA gerou algo **sintaticamente válido mas semanticamente perigoso**. E `terraform validate` não pegou, porque a sintaxe está correta.

Em outro cenário, a IA gera um Helm chart com `apiVersion: extensions/v1beta1` — uma API que foi removida no Kubernetes 1.22. O `helm template` renderiza sem erro (é Go template válido), mas `kubectl apply` falha no cluster real.

Esses são exemplos de **alucinações em IaC**: código que parece correto, passa em validações básicas, mas está errado de formas que só aparecem mais tarde — às vezes em produção.

## Problema

Alucinações em texto são inconvenientes. Alucinações em código de infraestrutura causam:
- **Exposição de segurança** — portas abertas, RBAC permissivo
- **Custos inesperados** — replicas: 100, instances com GPU
- **Downtime** — APIs deprecated que falham no cluster real
- **Perda de dados** — volumes sem backup, namespaces deletados

O código parece certo. As ferramentas de lint passam. O dano só aparece depois do apply.

## Teoria

### Por que LLMs alucinam especificamente em IaC

| Causa | Explicação | Exemplo |
|-------|-----------|---------|
| **Providers mudam** | Modelo treinado com versão antiga do provider | Argumento `restart_policy` no lugar errado |
| **APIs são deprecated** | Milhares de exemplos antigos no treinamento | `extensions/v1beta1` em vez de `apps/v1` |
| **Sem acesso ao state** | Modelo não sabe o que existe no cluster | Sugere criar algo que conflita |
| **Valores plausíveis ≠ corretos** | Qualquer número é YAML válido | `replicas: 50` num k3s single-node |
| **Imagens inventadas** | Modelo gera nomes que parecem reais | `prom/metrics-collector` (não existe) |
| **Mistura de providers** | Padrão sintático similar entre clouds | Argumento AWS aparece em config Azure |

### Taxonomia de alucinações em IaC

#### Tipo 1: Sintática — ferramenta pega

```hcl
# terraform validate DETECTA
resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
  }
  spec {
    restart_policy = "Always"  # ← argumento não existe neste bloco
  }
}
```

**Detecção:** `terraform validate`, `helm lint`
**Risco:** Baixo (falha antes do apply)

#### Tipo 2: Referência — terraform init pega

```hcl
# terraform init DETECTA
terraform {
  required_providers {
    kubernetes-extensions = {
      source  = "hashicorp/kubernetes-extensions"  # ← provider não existe
      version = "~> 1.0"
    }
  }
}
```

**Detecção:** `terraform init`
**Risco:** Baixo (falha antes do plan)

#### Tipo 3: API deprecated — cluster pega

```yaml
# kubectl apply --dry-run=server DETECTA
apiVersion: extensions/v1beta1   # ← removido no K8s 1.22
kind: Deployment
metadata:
  name: app
```

**Detecção:** `kubectl apply --dry-run=server`
**Risco:** Médio (falha no deploy, não no lint)

#### Tipo 4: Semântica — só humano pega

```hcl
# NENHUMA ferramenta detecta — parece 100% correto
resource "kubernetes_role" "app" {
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]    # ← admin no namespace inteiro
  }
}
```

**Detecção:** Review humano, OPA/Kyverno policies
**Risco:** ALTO (aplica com sucesso, cria vulnerabilidade silenciosa)

#### Tipo 5: Valores absurdos — só contexto pega

```hcl
# terraform plan APLICA sem erro
resource "kubernetes_deployment" "collector" {
  spec {
    replicas = 50    # ← para um k3s single-node com 4GB RAM?
    template {
      spec {
        container {
          resources {
            limits = {
              memory = "16Gi"   # ← node inteiro tem 4Gi
              cpu    = "4"      # ← node inteiro tem 4 vCPUs
            }
          }
        }
      }
    }
  }
}
```

**Detecção:** Conhecimento do ambiente (ResourceQuota pode bloquear)
**Risco:** Alto (consome todos os recursos do node ou falha com Pending)

---

### O pipeline de defesa contra alucinações

```
Código gerado pela IA
        ↓
┌─────────────────────────────────────────────────────┐
│ Camada 1: terraform validate / helm lint            │  ← Sintaxe
│           Pega: erros de tipo, argumentos inválidos │
├─────────────────────────────────────────────────────┤
│ Camada 2: terraform init                            │  ← Referências
│           Pega: providers inexistentes              │
├─────────────────────────────────────────────────────┤
│ Camada 3: terraform plan / helm template            │  ← Semântica parcial
│           Pega: conflitos, resources inesperados    │
├─────────────────────────────────────────────────────┤
│ Camada 4: kubectl apply --dry-run=server            │  ← API real
│           Pega: APIs deprecated, CRDs ausentes      │
├─────────────────────────────────────────────────────┤
│ Camada 5: OPA/Kyverno policies                      │  ← Políticas
│           Pega: sem limits, imagem :latest, RBAC *  │
├─────────────────────────────────────────────────────┤
│ Camada 6: Review humano                             │  ← Julgamento
│           Pega: valores absurdos, lógica de negócio │
└─────────────────────────────────────────────────────┘
        ↓
Código seguro para apply
```

**Regra prática:** Quanto mais "camadas" de validação passam, mais seguro é o apply. Nenhuma camada sozinha pega tudo.

---

### Checklist de validação pós-geração

Usar SEMPRE que a IA gerar código de infraestrutura:

| # | Pergunta | Ferramenta |
|---|----------|-----------|
| 1 | Sintaxe válida? | `terraform validate` / `helm lint` |
| 2 | Provider/imagem existe? | `terraform init` / `docker pull` |
| 3 | API version correta para meu cluster? | `kubectl apply --dry-run=server` |
| 4 | Permissões são mínimas? (sem `*`) | Review humano |
| 5 | Valores numéricos fazem sentido para o ambiente? | Review humano |
| 6 | Imagens com tag fixa? (sem `:latest`) | Grep / lint |
| 7 | Secrets estão em variáveis `sensitive`? (sem hardcode) | Grep / scan |
| 8 | O `terraform plan` mostra apenas o esperado? | Review do plan |

---

## Exemplos para demonstração ao vivo

### Exemplo 1 — Pedir algo impossível e ver a IA inventar

```
Prompt: "Gere Terraform usando o provider hashicorp/kubernetes-extensions para criar um CronJob"
```

Resultado: A IA gera código perfeito para um provider que NÃO EXISTE. Demonstra que o modelo não valida se o que ele referencia é real.

### Exemplo 2 — Pedir código e verificar valores

```
Prompt: "Gere um Deployment para um serviço simples de healthcheck no k3s single-node"
```

O que verificar no output:
- Replicas: mais que 3 é suspeito para um health check
- Memory limits: mais que 256Mi é suspeito
- Image: existe no Docker Hub?
- Tag: é fixa ou `:latest`?

### Exemplo 3 — Código que passa em TUDO exceto review humano

```hcl
# Este código passa em terraform validate, init, e plan.
# Só review humano pega o problema.

resource "kubernetes_network_policy" "allow_all" {
  metadata {
    name      = "default-policy"
    namespace = "production"
  }
  spec {
    pod_selector {}     # ← aplica a TODOS os pods
    ingress {
      # sem "from" = aceita tráfego de QUALQUER origem
    }
    policy_types = ["Ingress"]
  }
}
```

NetworkPolicy que existe mas não protege nada. Pior que não ter — dá falsa sensação de segurança.

---

## Pontos-chave

1. **`terraform validate` não é suficiente** — Valida sintaxe, não semântica. A maioria das alucinações perigosas passa pelo validate.
2. **`terraform plan` é seu maior aliado** — Mostra O QUE será criado. Se não ler o plan, está voando às cegas.
3. **Alucinação semântica > sintática em perigo** — Erro de sintaxe falha rápido e ruidosamente. Valor errado vai silenciosamente para produção.
4. **A IA não tem acesso ao estado real** — Não sabe o que existe no cluster, quanto recurso o node tem, nem qual versão de API está disponível.
5. **Review humano é insubstituível para segurança** — Nenhuma ferramenta automatizada substitui o julgamento "isso faz sentido para nosso ambiente?".
6. **Pressão de tempo é inimiga da validação** — Os piores incidentes com IA acontecem quando alguém pula etapas por pressa. O pipeline de defesa existe para ser seguido sempre.
