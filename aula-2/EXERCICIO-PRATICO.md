# Exercício Prático — Aula 2: Prompt Engineering com Kiro CLI

## Objetivo
Praticar a construção de prompts estruturados usando o Kiro CLI no terminal, comparar resultados entre prompts ruins e bons, e montar sua biblioteca pessoal.

---

## Exercício 1 — Prompt ruim vs. bom (5 min)

### 1a. Envie o prompt ruim:
```bash
kiro chat "cria um deployment kubernetes"
```
Observe: o output é genérico? Faltam limits? Probes? Labels?

### 1b. Envie o prompt bom:
```bash
kiro chat "Papel: Engenheiro de infra senior em Kubernetes.

Contexto: k3s single-node, namespace ai-iac-lab.

Crie um Deployment para:
- Nome: order-api
- Imagem: hashicorp/http-echo:0.2.3
- Porta: 5678
- Replicas: 2
- Args: [\"-text=order-api running\"]

Restrições:
- Resource limits: CPU 100m, memory 128Mi
- Liveness probe em / porta 5678
- Labels: app=order-api, version=0.2.3, managed-by=kiro
- SecurityContext: runAsNonRoot

Formato: YAML válido pronto para kubectl apply"
```

### Compare:
- Qual tem resource limits?
- Qual tem probes?
- Qual funciona no primeiro `kubectl apply`?

---

## Exercício 2 — Troubleshooting com logs reais (10 min)

### 2a. Simule o problema no k3s:
```bash
# Criar um pod que vai crashar (sem banco disponível)
kubectl run order-api --image=postgres:15 \
  --env="PGHOST=localhost" --env="PGPORT=5432" \
  -n ai-iac-lab --restart=Always

# Aguardar CrashLoopBackOff
sleep 30
kubectl get pods -n ai-iac-lab
```

### 2b. Coletar logs e diagnosticar:
```bash
# Coletar logs
LOGS=$(kubectl logs order-api -n ai-iac-lab --tail=20 2>&1)

# Enviar para diagnóstico
kiro chat "Papel: SRE senior em Kubernetes.

Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod order-api em CrashLoopBackOff
Restarts: $(kubectl get pod order-api -n ai-iac-lab -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo 'N/A')

Logs:
$LOGS

O que já tentei: restart do pod

Causa raiz e próximo passo concreto?"
```

### 2c. Usar log simulado (alternativa):
```bash
kiro chat "Papel: SRE senior em Kubernetes.

Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod order-api em CrashLoopBackOff há 10 min
Restarts: 5

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

O que já tentei: restart do pod, verificar Service postgres (não existe)

Causa raiz e próximo passo concreto?
Formato: diagnóstico + 3 ações priorizadas."
```

---

## Exercício 3 — Análise de logs com pré-processamento (10 min)

### 3a. Técnica de filtragem:
```bash
# Simular: filtrar apenas linhas relevantes
cat ~/ai-iac-labs/aula-2/logs-simulados/slow-response.log | grep -iE "error|warn|timeout"
```

### 3b. Enviar filtrado para análise:
```bash
FILTERED=$(cat ~/ai-iac-labs/aula-2/logs-simulados/slow-response.log | grep -iE "error|warn|timeout")

kiro chat "Papel: SRE analisando degradação de performance.

Serviço: order-api no k3s
Sintoma: respostas lentas (>5s), timeouts
Início: ~10:18

Identifique:
1. Padrões repetidos
2. Timestamp de início
3. Cadeia de eventos (causa → efeito)
4. Causa raiz

Formato: timeline + causa raiz + 3 ações urgentes

Logs filtrados (error/warn/timeout):
$FILTERED"
```

### 3c. Comparar com OOMKilled:
```bash
kiro chat "Papel: SRE especializado em troubleshooting de memória.

Ambiente: k3s, namespace ai-iac-lab
Pod: email-worker, limit 128Mi, OOMKilled

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/oom-killed.log)

1. Causa do consumo excessivo?
2. Aumentar limit ou corrigir config?
3. Métricas para prevenir recorrência?"
```

---

## Exercício 4 — Geração de Helm Chart (15 min)

### 4a. Gerar chart com prompt estruturado:
```bash
kiro chat "Papel: Engenheiro de infra senior em Helm/Kubernetes.

Contexto: k3s single-node, namespace ai-iac-lab.

Gere um Helm chart completo:
- Nome: order-api
- Imagem: hashicorp/http-echo:0.2.3
- Porta: 5678
- Replicas: 2
- Args: [\"-text=order-api running\"]
- Limits: cpu=100m, memory=128Mi
- Liveness/readiness: GET / porta 5678
- Service type: ClusterIP

Restrições:
- Labels padrão kubernetes (app.kubernetes.io/*)
- SecurityContext: runAsNonRoot, readOnlyRootFilesystem
- values.yaml parametrizado

Formato: cada arquivo separado (Chart.yaml, values.yaml, templates/)"
```

### 4b. Salvar e validar:
```bash
# Criar estrutura
mkdir -p ~/ai-iac-labs/aula-2/exercicio-helm/templates
cd ~/ai-iac-labs/aula-2/exercicio-helm

# (colar arquivos gerados pelo Kiro)

# Validar
helm lint .
helm template test .

# Instalar no k3s
helm install order-api . -n ai-iac-lab --create-namespace

# Verificar
kubectl get pods -n ai-iac-lab
kubectl get svc -n ai-iac-lab
```

### 4c. Iterar — pedir correções:
```bash
# Se helm lint falhar, enviar o erro de volta:
kiro chat "O helm lint retornou este erro:
$(helm lint . 2>&1)

Corrija o chart mantendo as mesmas specs."
```

---

## Exercício 5 — Crie seu próprio prompt (10 min)

Escolha um cenário do seu dia a dia e crie um prompt seguindo a estrutura:

```
Papel: [quem a IA deve ser]
Contexto: [ambiente, serviço, situação]
Instrução: [o que fazer]
Restrições: [limites, padrões, segurança]
Formato: [como quer o output]
```

Salve em `~/ai-iac-labs/aula-2/prompts/` na categoria adequada.

---

## Checklist de aprendizado

- [ ] Entendi a diferença entre prompt sem estrutura e com estrutura
- [ ] Sei filtrar logs antes de enviar para a IA
- [ ] Consigo gerar manifests funcionais no primeiro try
- [ ] Sei iterar com a IA quando o output tem erros
- [ ] Criei pelo menos 1 prompt próprio na biblioteca
