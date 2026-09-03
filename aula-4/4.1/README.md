# 4.1 — O que são agentes de IA e como diferem de chatbots

## Contexto

Até aqui no curso, você usou IA de um jeito: perguntou, recebeu texto. Pediu um Terraform, recebeu código. Pediu análise de log, recebeu diagnóstico. Sempre no modelo **pergunta → resposta**.

Mas pense numa situação real: são 3h da manhã, alerta disparou, o serviço `order-api` está fora. Você abre o terminal, cola os logs no chat, recebe um diagnóstico, copia o comando sugerido, cola no terminal, executa, volta pro chat, cola o resultado, pede próximo passo... Você virou um **proxy humano** entre a IA e o terminal.

Agora imagine outro cenário: você abre o agente e diz "o order-api está com CrashLoopBackOff no namespace ai-iac-lab, investiga e resolve". O agente **executa** `kubectl get pods`, **analisa** o output, **decide** que precisa ver logs, **executa** `kubectl logs`, **identifica** a causa, **propõe** uma correção, **pergunta** se pode aplicar, e **aplica**. Um único pedido, múltiplas ações encadeadas.

Essa é a diferença fundamental entre chatbot e agente.

## Problema

A diferença entre "IA que gera texto" e "IA que executa ações" não é apenas técnica — é de **risco**. Texto errado é inconveniente. Ação errada pode derrubar produção. Sem entender essa diferença, profissionais de infra podem dar autonomia demais para uma ferramenta sem as proteções adequadas.

## Teoria

### O que é um chatbot

```
Humano: "como resolver CrashLoopBackOff?"
   ↓
LLM: gera texto explicativo
   ↓
Humano: lê, interpreta, executa manualmente
```

- Input: texto
- Output: texto
- Ações: nenhuma (quem age é o humano)
- Risco: baixo (texto errado não quebra nada)

### O que é um agente

```
Humano: "resolve o CrashLoopBackOff do order-api"
   ↓
┌────────────────────────────────────┐
│         LOOP DO AGENTE             │
│                                    │
│  1. OBSERVAR  → kubectl get pods   │
│  2. RACIOCINAR → "pod em crash,    │
│                   preciso ver logs" │
│  3. AGIR      → kubectl logs ...   │
│  4. OBSERVAR  → analisa output     │
│  5. RACIOCINAR → "falta o service  │
│                   do postgres"     │
│  6. AGIR      → kubectl apply ...  │
│  7. VERIFICAR → pod Running? ✓     │
│                                    │
└────────────────────────────────────┘
   ↓
Humano: recebe o problema resolvido
```

- Input: objetivo em linguagem natural
- Output: ações executadas no mundo real
- Ações: lê estado, executa comandos, verifica resultados
- Risco: alto (uma ação errada tem consequências reais)

### Os componentes de um agente

| Componente | O que faz | Exemplo em infra |
|-----------|-----------|------------------|
| **LLM** | Raciocina e decide próximo passo | Analisa logs e decide o que investigar |
| **Tools** | Executa ações no ambiente | kubectl, helm, terraform, shell |
| **Loop** | Repete até resolver ou desistir | Tentar fix → verificar → se falhou, tentar outra coisa |
| **Memória** | Lembra do que já tentou | "Já reiniciei o pod e não resolveu, preciso olhar o service" |

### Exemplo concreto: Kiro CLI como agente

Quando você pede ao Kiro "faça deploy deste chart no k3s", ele:

1. Executa `helm install` (tool use)
2. Verifica o resultado com `kubectl get pods`
3. Se o pod não sobe, lê os logs
4. Identifica o erro (ex: imagem não encontrada)
5. Corrige o values.yaml
6. Tenta novamente

Isso é um agente — simples, mas funcional. Você já usou nas aulas anteriores sem perceber.

### A grande diferença: o que acontece quando a IA erra

| Cenário | Chatbot | Agente |
|---------|---------|--------|
| IA sugere `replicas: 100` | Você lê, percebe o absurdo, ignora | Agente aplica, 100 pods sobem, node crasheia |
| IA sugere RBAC com `verbs: ["*"]` | Você revisa no PR, corrige | Agente aplica, todo pod vira admin |
| IA confunde namespace | Texto mostra "production", você percebe | Agente executa no namespace errado |

**Conclusão:** Agentes precisam de guardrails. Chatbots precisam de senso crítico humano. Ambos precisam de validação.

---

## Exemplo para demonstração ao vivo

### Modo chatbot

```
Prompt: "Como eu descubro por que um pod está em CrashLoopBackOff?"

Resposta esperada (texto explicativo):
1. Execute kubectl describe pod <nome> -n <namespace>
2. Verifique a seção "Events" e "Last State"
3. Execute kubectl logs <pod> -n <namespace> --previous
4. Procure por erros de conexão, OOM, ou configuração...
```

O humano precisa copiar cada comando, executar, interpretar, e decidir o próximo passo.

### Modo agente

```
Prompt: "O pod order-api está em CrashLoopBackOff no namespace ai-iac-lab. Investigue e resolva."

Comportamento esperado:
→ Executa: kubectl get pods -n ai-iac-lab
→ Analisa: "order-api 0/1 CrashLoopBackOff 5 restarts"
→ Executa: kubectl logs order-api -n ai-iac-lab
→ Analisa: "connection refused postgres-svc:5432"
→ Executa: kubectl get svc -n ai-iac-lab
→ Analisa: "não existe service postgres-svc"
→ Propõe: "Preciso criar o Service. Posso aplicar?"
→ [Humano aprova]
→ Executa: kubectl apply -f service-fix.yaml
→ Verifica: kubectl get pods -n ai-iac-lab → "Running ✓"
```

O humano deu UM comando. O agente resolveu em múltiplos passos.

---

## Pontos-chave

1. **Chatbot = texto. Agente = ação.** A diferença parece sutil mas muda completamente o perfil de risco.
2. **Você já usa agentes** — Kiro com tool use é um agente. O conceito não é futurista, é o que fizemos nas aulas 2 e 3.
3. **O loop é o diferencial** — Chatbots param na primeira resposta. Agentes iteram até resolver.
4. **Mais autonomia = mais risco** — Esse trade-off define todas as decisões de governança que veremos nas próximas aulas.
5. **O humano não sai do loop** — Mesmo com agentes, o papel do profissional é supervisionar, validar e decidir os gates de aprovação.
