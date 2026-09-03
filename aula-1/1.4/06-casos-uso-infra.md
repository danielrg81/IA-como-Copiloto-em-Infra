# Casos de Uso Reais: IA em DevOps e SRE

## Demonstração prática de 3 cenários que você vai usar no dia a dia.

---

## Caso 1 — Geração de IaC

### Cenário
Preciso de um Helm chart para um novo serviço. Sei o que quero mas não quero escrever boilerplate.

### Demo:
```bash
kiro chat "Gere um Helm chart mínimo para um serviço chamado notification-api.
- Imagem: nginx:1.25-alpine
- Porta: 8080
- 1 réplica
- Resource limits: cpu=50m, memory=64Mi
- Liveness probe em /healthz

Só os arquivos essenciais: Chart.yaml, values.yaml, templates/deployment.yaml, templates/service.yaml"
```

### Validar:
```bash
# Salvar output, depois:
helm lint ./notification-api
helm template test ./notification-api
```

### Valor: 5 minutos vs. 30 minutos escrevendo do zero.

---

## Caso 2 — Análise de Incidente

### Cenário
São 3h da manhã, alerta disparou, preciso entender rápido o que está acontecendo.

### Demo:
```bash
# Coletar dados
LOGS=$(kubectl logs -n ai-iac-lab deploy/order-api --tail=30 2>&1 || cat ~/ai-iac-labs/aula-2/logs-simulados/slow-response.log)

kiro chat "Papel: SRE de plantão analisando incidente.

Alerta: order-api com error rate > 30% há 5 minutos.
Ambiente: k3s, namespace ai-iac-lab.

Logs:
$LOGS

Me dê:
1. Causa raiz provável (1 frase)
2. Ação imediata para mitigar
3. O que investigar depois que estabilizar"
```

### Valor: Diagnóstico em 30 segundos vs. 10 minutos lendo logs manualmente.

---

## Caso 3 — Documentação / Runbook

### Cenário
Resolvi um incidente e preciso documentar o procedimento para o time.

### Demo:
```bash
kiro chat "Gere um runbook em Markdown para o seguinte procedimento:

Problema: pod order-api em CrashLoopBackOff por falta de conexão com postgres.
Causa: Service do postgres não existe no namespace.
Solução: criar o Service apontando para o pod do postgres.

Runbook deve ter:
- Título
- Sintomas (como identificar)
- Passos de resolução (comandos kubectl exatos)
- Validação (como confirmar que resolveu)
- Prevenção (como evitar recorrência)

Ambiente: k3s, namespace ai-iac-lab."
```

### Valor: Documentação pronta em 1 minuto vs. 20 minutos escrevendo.

---

## Resumo: Onde IA agrega valor em Infra

| Caso de Uso | Sem IA | Com IA | Ganho |
|---|---|---|---|
| Gerar Helm chart | 30 min | 5 min | 6x mais rápido |
| Diagnosticar incidente | 10 min lendo logs | 30 seg | Foco no que importa |
| Escrever runbook | 20 min | 1 min | Time tem doc atualizada |
| Refatorar Terraform | 1-2h | 15 min | Menos risco de erro |
| Code review de IaC | 30 min | 5 min | Checklist consistente |

## Onde IA NÃO substitui o humano

- **Decisão arquitetural** — IA não sabe seu contexto de negócio
- **Julgamento de risco** — IA não sabe o blast radius real
- **Responsabilidade** — quem faz apply é responsável, não a IA
- **Contexto organizacional** — políticas, compliance, cultura do time
