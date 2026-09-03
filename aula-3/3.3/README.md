# 3.3 — IA para Helm charts e templates

## Objetivo
Usar IA para gerar um Helm chart completo com helpers, conditionals, loops e validar no k3s.

## Pré-requisitos
```bash
helm version
kubectl get nodes
kubectl get ns ai-iac-lab || kubectl create ns ai-iac-lab
```

---

## Roteiro de Comandos

### Passo 1 — Entender a estrutura do chart
```bash
cd ~/ai-iac-labs/aula-3/3.3
tree chart-gerado/
```

Anatomia:
```
chart-gerado/
├── Chart.yaml              ← Metadados do chart
├── values.yaml             ← Valores configuráveis
└── templates/
    ├── _helpers.tpl        ← Funções reutilizáveis (não gera resource)
    ├── deployment.yaml     ← Template com conditionals
    ├── service.yaml        ← Template básico com helpers
    ├── configmap.yaml      ← Template com range loop
    ├── hpa.yaml            ← Template condicional (autoscaling)
    └── ingress.yaml        ← Template condicional (ingress)
```

### Passo 2 — Gerar o _helpers.tpl com IA
```bash
kiro chat < prompts/01-gerar-helpers.md
```

> **O que observar:** A IA usou `{{- define }}` e `{{- end }}`? Incluiu comentários? Compare com `chart-gerado/templates/_helpers.tpl`.

### Passo 3 — Gerar o deployment com conditionals
```bash
kiro chat < prompts/02-gerar-deployment.md
```

> **Pontos de falha comuns da IA:**
> - `nindent` com valor errado (indentação quebrada)
> - Esquece o `-` em `{{-` (espaços extras no YAML)
> - Contexto de `.` dentro de range (precisa de `$`)

### Passo 4 — Validar com helm template (sem instalar)
```bash
# Renderizar os templates localmente
helm template order-api ./chart-gerado -n ai-iac-lab

# Verificar apenas o deployment
helm template order-api ./chart-gerado -n ai-iac-lab -s templates/deployment.yaml

# Lint (valida boas práticas)
helm lint ./chart-gerado
```

> **Se der erro:** Cole o erro na IA e peça para corrigir. Helm template errors são ótimos para iterar.

### Passo 5 — Instalar no k3s
```bash
helm install order-api ./chart-gerado -n ai-iac-lab

# Verificar recursos criados
kubectl get all -n ai-iac-lab -l app.kubernetes.io/name=order-api
kubectl get configmap -n ai-iac-lab -l app.kubernetes.io/name=order-api

# Testar o serviço
kubectl run curl-test --rm -it --image=curlimages/curl -n ai-iac-lab -- \
  curl -s http://order-api:5678
```

### Passo 6 — Iterar: adicionar HPA
```bash
kiro chat < prompts/03-adicionar-hpa.md
```

Ativar o HPA via upgrade:
```bash
helm upgrade order-api ./chart-gerado -n ai-iac-lab \
  --set autoscaling.enabled=true

# Verificar
kubectl get hpa -n ai-iac-lab
kubectl get deployment order-api -n ai-iac-lab -o jsonpath='{.spec.replicas}'
# Deve estar vazio (HPA controla)
```

### Passo 7 — Iterar: ConfigMap com range
```bash
kiro chat < prompts/04-configmap-range.md
```

Testar com valores diferentes:
```bash
helm upgrade order-api ./chart-gerado -n ai-iac-lab \
  --set configMap.data.EXTRA_VAR=teste \
  --set autoscaling.enabled=false

# Ver o configmap renderizado
kubectl get configmap order-api-config -n ai-iac-lab -o yaml
```

### Passo 8 — Dry-run no server (validação máxima)
```bash
helm upgrade order-api ./chart-gerado -n ai-iac-lab \
  --set autoscaling.enabled=true \
  --set ingress.enabled=true \
  --dry-run
```

> **Por que dry-run no server?** Valida contra a API do Kubernetes (versões de API, CRDs existentes), não apenas sintaxe local.

### Passo 9 — Override de values para diferentes ambientes
```bash
# Simular ambiente de staging
helm template order-api ./chart-gerado -n ai-iac-lab \
  --set app.name=order-api-staging \
  --set replicaCount=1 \
  --set configMap.data.APP_ENV=staging \
  --set configMap.data.LOG_LEVEL=debug
```

### Passo 10 — Cleanup
```bash
helm uninstall order-api -n ai-iac-lab

# Confirmar
kubectl get all -n ai-iac-lab -l app.kubernetes.io/name=order-api
```

---

## Estrutura dos arquivos

```
3.3/
├── README.md                        ← Este roteiro
├── chart-gerado/                    ← Chart completo de referência
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── configmap.yaml
│       ├── hpa.yaml
│       └── ingress.yaml
└── prompts/                         ← Prompts para gerar cada parte
    ├── 01-gerar-helpers.md
    ├── 02-gerar-deployment.md
    ├── 03-adicionar-hpa.md
    └── 04-configmap-range.md
```

## Conceitos de Helm templates usados

| Conceito | Onde aparece | O que faz |
|----------|-------------|-----------|
| `{{- define }}` | _helpers.tpl | Define função reutilizável |
| `{{- include }}` | deployment, service | Chama helper com contexto |
| `nindent N` | Todos os templates | Indenta N espaços (crítico para YAML) |
| `{{- if }}` | hpa, ingress, configmap | Condicional — cria ou não o resource |
| `{{- range }}` | configmap | Loop sobre map/list |
| `toYaml` | deployment (resources) | Converte objeto Go em YAML |
| `| quote` | configmap | Garante aspas em valores |
| `.Release.Name` | service | Nome dado no `helm install` |
| `.Release.Namespace` | todos | Namespace do release |

## Erros comuns da IA com Helm templates

1. **nindent errado** — indentação quebra o YAML inteiro. Sempre validar com `helm template`.
2. **Falta o `-` em `{{-`** — gera linhas em branco no output.
3. **Contexto `.` dentro de range** — dentro de `{{ range }}`, `.` muda de escopo. Usar `$` para acessar o root.
4. **toYaml sem nindent** — gera YAML desalinhado.
5. **Quote em números** — `port: {{ .Values.port | quote }}` gera `port: "5678"` (string, não int).

## Pontos-chave para discussão

1. **helm template é seu melhor amigo** — renderiza sem instalar, mostra o YAML real
2. **helm lint** — pega problemas de boas práticas (chart sem description, etc.)
3. **Iteração com IA** — gerar parte por parte é mais eficaz que pedir chart inteiro
4. **IA erra indentação** — Go templates + YAML é uma combinação difícil para LLMs
5. **Conditionals** — permitem chart flexível (mesmo chart para dev/staging/prod)
