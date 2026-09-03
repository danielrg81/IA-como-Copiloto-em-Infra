# Exercício Prático — Comparando como cada IA pensa

## Objetivo
Observar na prática as diferenças de raciocínio, construção de resposta e comportamento iterativo entre Kiro CLI e Gemini CLI usando o mesmo prompt.

---

## Exercício 1 — Mesmo prompt, duas ferramentas (10 min)

### 1a. Execute no Kiro CLI:
```bash
kiro chat "Antes de responder, explique passo a passo como você vai resolver.
Depois, gere um Deployment Kubernetes para nginx com:
- 2 replicas
- Liveness probe em /healthz
- Resource limits: 256Mi RAM, 200m CPU
- Labels: app=web, env=production"
```

### 1b. Execute no Gemini CLI:
```bash
gemini "Antes de responder, explique passo a passo como você vai resolver.
Depois, gere um Deployment Kubernetes para nginx com:
- 2 replicas
- Liveness probe em /healthz
- Resource limits: 256Mi RAM, 200m CPU
- Labels: app=web, env=production"
```

### 1c. Preencha a tabela:

| Dimensão | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| Quantos passos de raciocínio mostrou? | | |
| Explicou antes ou depois do código? | | |
| O YAML funciona de primeira? | | |
| Adicionou algo que você não pediu? | | |
| Fez alguma pergunta de clarificação? | | |

### 1d. Valide os outputs:
```bash
kubectl apply --dry-run=server -f output-kiro.yaml
kubectl apply --dry-run=server -f output-gemini.yaml
```

---

## Exercício 2 — Teste de memória e iteração (10 min)

Na **mesma sessão** de cada ferramenta, envie 3 prompts em sequência:

### Prompt 1:
```
Gere um Deployment nginx básico com 1 replica no namespace ai-iac-lab.
```

### Prompt 2:
```
Agora adicione um HPA com target de 70% de CPU, min 1 e max 5 replicas.
```

### Prompt 3:
```
Tem algum problema de segurança no que você gerou até agora?
```

### Preencha:

| Pergunta | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| No prompt 2, lembrou do deployment anterior? | | |
| No prompt 2, gerou só o HPA ou reescreveu tudo? | | |
| No prompt 3, identificou problemas reais? | | |
| No prompt 3, sugeriu correções concretas? | | |

---

## Exercício 3 — Diagnóstico sob pressão (10 min)

Use o log simulado para testar capacidade de análise:

### No Kiro CLI:
```bash
kiro chat "Pod order-api em CrashLoopBackOff. Diagnostique:

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Quero: causa raiz + 3 ações priorizadas + comando exato para cada ação."
```

### No Gemini CLI:
```bash
gemini "Pod order-api em CrashLoopBackOff. Diagnostique:

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Quero: causa raiz + 3 ações priorizadas + comando exato para cada ação."
```

### Compare:

| Critério | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| Identificou a causa raiz correta? | | |
| Comandos sugeridos estão corretos? | | |
| Priorizou as ações de forma lógica? | | |
| Tempo até resposta útil | | |

---

## Exercício 4 — Mapa de decisão pessoal (5 min)

Com base nos exercícios anteriores, preencha seu mapa de decisão:

| Quando preciso... | Vou usar... | Porque... |
|-------------------|-------------|-----------|
| Gerar código rápido e direto | | |
| Analisar problema complexo com logs | | |
| Iterar e refinar uma solução | | |
| Explicação rápida de um erro | | |
| Pipeline completo (gerar + validar + deploy) | | |

---

## Conclusão

Não existe ferramenta "melhor" — existe a mais adequada para cada tipo de tarefa:
- **Tipo "arquiteto"**: pensa antes, justifica, mantém contexto longo → problemas complexos
- **Tipo "executor"**: responde rápido, vai direto ao ponto → tarefas bem definidas

O profissional eficiente alterna entre as duas conforme a necessidade.
