# 4.2 — O mercado de agentes: frameworks, maturidade e autonomia gradual

## Contexto

Seu time adotou Kiro CLI e Gemini CLI no dia a dia. A produtividade subiu. O gestor leu um artigo sobre "AI agents that auto-remediate incidents" e agora quer saber: "dá pra fazer um agente que resolva alertas sozinho? Vi que a empresa X economizou 60% do tempo de on-call."

Você precisa responder com propriedade: o que existe, o que funciona, o que é hype. Porque o risco aqui é duplo — ignorar algo que já está maduro (perder produtividade) ou adotar algo imaturo (criar incidentes).

## Problema

O hype é grande mas a maturidade é desigual. Frameworks como LangChain, CrewAI e AutoGen aparecem em todo post de blog, mas a realidade em produção é diferente. O profissional precisa de um mapa claro: o que funciona HOJE em operações, o que é viável em 6 meses, e o que ainda é pesquisa.

## Teoria

### Arquitetura genérica de um agente

Independente do framework, todo agente de operações tem a mesma estrutura:

```
┌─────────────────────────────────────────────────────────┐
│                    ORQUESTRADOR                          │
│                                                         │
│  ┌───────────┐   ┌────────────┐   ┌─────────────────┐  │
│  │ TRIGGER   │   │   LLM      │   │   FERRAMENTAS   │  │
│  │           │   │            │   │                 │  │
│  │ • Alerta  │ → │ • Raciocina│ → │ • kubectl       │  │
│  │ • Cron    │   │ • Planeja  │   │ • helm          │  │
│  │ • Humano  │   │ • Decide   │   │ • terraform     │  │
│  │ • Webhook │   │            │   │ • APIs          │  │
│  └───────────┘   └────────────┘   └─────────────────┘  │
│                                                         │
│  ┌───────────┐   ┌────────────────────────────────────┐ │
│  │ MEMÓRIA   │   │         GUARDRAILS                 │ │
│  │           │   │                                    │ │
│  │ • Contexto│   │ • RBAC (permissões)               │ │
│  │ • Histórico   │ • Dry-run obrigatório             │ │
│  │ • State   │   │ • Aprovação humana                │ │
│  └───────────┘   │ • Timeout e retry limits          │ │
│                   └────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Os 3 frameworks principais

#### LangChain — O canivete suíço

**O que é:** O framework mais popular e maduro para construir agentes. Funciona como uma "cola" entre LLMs e ferramentas externas.

**Conceito central:** Chains (sequências de chamadas) e Agents (loops de decisão com tools).

**Exemplo em infra — Agente de diagnóstico de incidente:**

```
Trigger: Alerta PagerDuty "order-api error rate > 30%"
   ↓
Tool 1: Consultar CloudWatch (últimos 5 min de logs)
   ↓
Tool 2: Buscar deploys recentes (GitHub API)
   ↓
LLM: "Deploy v2.3.1 há 8 min coincide com início dos erros.
      Logs mostram connection timeout ao Redis.
      Causa provável: nova versão mudou config de conexão."
   ↓
Output: Diagnóstico + sugestão de rollback
```

| Prós | Contras |
|------|---------|
| Enorme ecossistema de integrações | Complexidade alta para casos simples |
| Documentação extensa | API muda frequentemente |
| Comunidade muito ativa | Abstração excessiva (muitas camadas) |
| Suporta Python e JavaScript | Curva de aprendizado íngreme |

**Quando usar:** Integrações complexas com múltiplas APIs e fontes de dados.

---

#### CrewAI — O time de especialistas

**O que é:** Framework focado em multi-agentes colaborativos — vários agentes com papéis diferentes trabalhando juntos numa "equipe".

**Conceito central:** "Crew" (equipe) onde cada agente tem um papel definido e entregam trabalho sequencialmente.

**Exemplo em infra — Crew de code review:**

```
┌──────────────────────────────────────────────────────┐
│                 CREW: "IaC Review"                    │
│                                                      │
│  Agente "SRE"         →  Diagnostica o problema      │
│  "Analisei os logs.      (encontra causa raiz)       │
│   Redis connection                                   │
│   timeout após deploy                                │
│   v2.3.1"                                            │
│         ↓                                            │
│  Agente "DevOps"      →  Propõe solução              │
│  "Sugiro rollback         (gera código/comandos)     │
│   para v2.3.0 e                                      │
│   investigar a config                                │
│   de Redis na v2.3.1"                                │
│         ↓                                            │
│  Agente "Reviewer"    →  Valida segurança            │
│  "Rollback é seguro.     (aprova ou bloqueia)        │
│   Blast radius baixo.                                │
│   APROVADO."                                         │
└──────────────────────────────────────────────────────┘
```

| Prós | Contras |
|------|---------|
| Simples de configurar | Menos controle fino |
| Abstração de alto nível | Menos integrações que LangChain |
| Bom para workflows com papéis | Agentes podem "conversar demais" |
| Fácil de entender | Overhead de coordenação |

**Quando usar:** Workflows onde diferentes "especialistas" precisam colaborar em sequência.

---

#### AutoGen (Microsoft) — A mesa redonda

**O que é:** Framework para conversas multi-agente onde agentes dialogam entre si para resolver problemas, com possibilidade de incluir humano no loop.

**Conceito central:** Agentes que conversam em grupo, debatem alternativas, e chegam a uma conclusão.

**Exemplo em infra — Discussão de estratégia de migração:**

```
Agente "Arquiteto": "Proponho migrar o PostgreSQL para RDS.
                     Benefício: managed service, backups automáticos."

Agente "SRE":       "Risco: downtime de 4h na migração.
                     O SLA permite? Alternativa com blue-green?"

Agente "Arquiteto": "Blue-green com replicação async.
                     Zero downtime, mas complexidade maior."

Agente "FinOps":    "RDS r6g.large = $180/mês vs. EC2 atual $95/mês.
                     ROI positivo se considerar tempo de operação."

Humano:             "Aprovado blue-green. Gerem o plano de execução."
```

| Prós | Contras |
|------|---------|
| Natural para decisão colaborativa | Lento (muita "conversa") |
| Fácil incluir humano no loop | Custoso em tokens |
| Bom para brainstorming | Menos focado em execução |
| Debate expõe trade-offs | Pode ficar circular |

**Quando usar:** Decisões complexas que precisam considerar múltiplas perspectivas antes de agir.

---

### Comparativo resumido

| Aspecto | LangChain | CrewAI | AutoGen |
|---------|-----------|--------|---------|
| Foco | Chains + tools | Multi-agente sequencial | Conversação em grupo |
| Complexidade | Alta | Média | Média |
| Maturidade | Alta | Média | Média |
| Melhor para | Integrações complexas | Workflows com papéis | Decisão colaborativa |
| Linguagem | Python / JS | Python | Python |
| Execução | Agente único com muitas tools | Múltiplos agentes em série | Múltiplos agentes em debate |

---

### Conceito-chave: Autonomia Gradual

Não é binário — "chatbot" ou "agente autônomo". É um espectro:

```
Nível 0           Nível 1                Nível 2               Nível 3
INFORMAR     →    SUGERIR + ESPERAR  →   AGIR + MONITORAR  →  AUTÔNOMO
                                                               (escopo limitado)

"O pod está       "Sugiro fazer           "Fiz rollback.        "Detectei OOM,
 em crash.         rollback.               Monitorando          escalei para 3
 Aqui estão        Confirma?"              por 5 min..."        réplicas
 os logs."                                                      automaticamente."
```

**Critério prático para decidir o nível:**

| Se o blast radius é... | Autonomia máxima aceitável |
|------------------------|---------------------------|
| Nenhum (read-only) | Nível 3 — livre |
| Namespace de teste | Nível 2-3 |
| Staging | Nível 1-2 |
| Produção (baixo impacto) | Nível 1 |
| Produção (alto impacto) | Nível 0 |

---

### O que funciona HOJE vs. o que é futuro

| ✅ Viável hoje (2024-2025) | ⏳ Experimental (6-12 meses) | 🔮 Futuro (1-2 anos) |
|---------------------------|------------------------------|---------------------|
| Geração assistida de IaC (Kiro, Copilot) | Auto-remediação de incidentes simples | Agentes autônomos de operações |
| Troubleshooting guiado com logs | Pipeline IaC com review automatizado | Multi-agente em produção |
| Code review assistido por IA | Agente de observability integrado | Provisionamento autônomo |
| Documentação gerada automaticamente | Rollback automático baseado em health | Capacity planning preditivo |
| Conversão entre formatos (YAML↔JSON↔HCL) | Chat-ops com execução (aprovação via Slack) | Self-healing infrastructure |

---

## Exemplo prático: "Agente" que você já pode montar hoje

Sem nenhum framework, só com o que já temos:

```
1. Alerta chega (webhook ou cron checando health)
2. Script coleta contexto (kubectl get pods, logs, describe)
3. Contexto é enviado ao LLM (kiro chat --no-interactive)
4. LLM retorna diagnóstico + ação sugerida
5. Humano aprova (ou rejeita)
6. Script executa a ação aprovada
7. Script verifica resultado e reporta
```

Isso é um agente de nível 1. Sem LangChain, sem CrewAI. Só shell script + LLM + ferramentas que já conhecemos.

**A lição:** frameworks resolvem complexidade de orquestração. Se seu caso é simples, não precisa de framework — precisa de um bom script.

---

---

## Deep Dive: Os 3 frameworks em detalhe

### LangChain — O canivete suíço (em detalhe)

#### O que é na prática

LangChain é um framework Python/JS que conecta um LLM a ferramentas externas num loop de decisão. O modelo não apenas gera texto — ele **decide qual ferramenta usar, executa, lê o resultado, e decide o próximo passo**.

> **Nota 2026:** O ecossistema LangChain se dividiu — LangChain para RAG/chains simples, **LangGraph** (v1.0 desde out/2025) para agentes stateful com máquina de estados em grafo. Quando falamos de agentes, estamos falando de LangGraph.

#### Como funciona por dentro

```
Usuário: "Por que o order-api está com latência alta?"
         ↓
┌─────────────────────── LOOP DO AGENTE ───────────────────────┐
│                                                               │
│  LLM pensa: "Preciso ver os pods primeiro"                    │
│       ↓                                                       │
│  Chama tool: kubectl get pods -n production                   │
│       ↓                                                       │
│  Recebe resultado: "order-api 3/3 Running, redis 0/1 Error"  │
│       ↓                                                       │
│  LLM pensa: "Redis com erro. Preciso ver os logs"             │
│       ↓                                                       │
│  Chama tool: kubectl logs redis-0 --tail=50                   │
│       ↓                                                       │
│  Recebe resultado: "OOM Killed..."                            │
│       ↓                                                       │
│  LLM pensa: "Tenho informação suficiente para responder"      │
│       ↓                                                       │
│  Resposta final: "Redis está com OOM. Sugestão: aumentar      │
│  memory limit de 256Mi para 512Mi"                            │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

#### Conceitos-chave

| Conceito | O que é | Analogia |
|----------|---------|----------|
| **Chain** | Sequência fixa de passos (A→B→C) | Script linear |
| **Agent** | Loop de decisão — o LLM escolhe o próximo passo | Profissional pensando |
| **Tool** | Função que o agente pode chamar (API, CLI, banco) | Ferramenta na bancada |
| **Memory** | Histórico de interações para manter contexto | Caderno de anotações |

#### Código simplificado (pseudo-código para ilustrar)

```python
from langchain.agents import create_tool_calling_agent
from langchain.tools import tool

@tool
def kubectl(command: str) -> str:
    """Executa comando kubectl e retorna output"""
    return subprocess.run(["kubectl"] + command.split(), capture_output=True).stdout

@tool
def helm_status(release: str) -> str:
    """Verifica status de um release Helm"""
    return subprocess.run(["helm", "status", release], capture_output=True).stdout

agent = create_tool_calling_agent(
    llm=ChatOpenAI(model="gpt-4"),
    tools=[kubectl, helm_status]
)

agent.invoke("Por que o order-api está lento?")
# O agente decide sozinho quais tools chamar e em que ordem
```

#### Quando faz sentido

- Agente **único** que precisa acessar **muitas ferramentas** diferentes
- Integrações complexas (CloudWatch + GitHub + PagerDuty + Slack)
- Quando você quer controle granular sobre cada passo

#### Quando NÃO faz sentido

- Caso simples que um script de 20 linhas resolve
- Quando a curva de aprendizado não justifica o ganho

---

### CrewAI — O time de especialistas (em detalhe)

#### O que é na prática

CrewAI organiza **múltiplos agentes como uma equipe**. Cada agente tem um papel (role), um objetivo (goal) e uma história de fundo (backstory) que direciona seu comportamento. Eles trabalham em sequência, passando o resultado de um para o próximo.

#### Como funciona por dentro

```
┌────────────────────────────────────────────────────────────────┐
│                    CREW: "Incident Response"                     │
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐       │
│  │  AGENTE 1: "SRE Investigador"                        │       │
│  │  Role: Investigar incidentes analisando métricas     │       │
│  │  Goal: Encontrar a causa raiz do problema            │       │
│  │                                                      │       │
│  │  → Analisa logs, métricas, eventos recentes          │       │
│  │  → Output: "Redis OOM após deploy v2.3.1"           │       │
│  └──────────────────────────────────────────────────────┘       │
│              │ (passa resultado para o próximo)                   │
│              ↓                                                    │
│  ┌──────────────────────────────────────────────────────┐       │
│  │  AGENTE 2: "DevOps Engineer"                         │       │
│  │  Role: Propor soluções técnicas para problemas       │       │
│  │  Goal: Gerar fix com menor blast radius              │       │
│  │                                                      │       │
│  │  → Recebe diagnóstico do agente anterior             │       │
│  │  → Output: "helm upgrade redis --set memory=512Mi"   │       │
│  └──────────────────────────────────────────────────────┘       │
│              │                                                    │
│              ↓                                                    │
│  ┌──────────────────────────────────────────────────────┐       │
│  │  AGENTE 3: "Security Reviewer"                       │       │
│  │  Role: Validar que mudanças não introduzem risco     │       │
│  │  Goal: Aprovar ou bloquear com justificativa         │       │
│  │                                                      │       │
│  │  → Valida: permissões OK? Blast radius aceitável?    │       │
│  │  → Output: "APROVADO — change é namespace-scoped"    │       │
│  └──────────────────────────────────────────────────────┘       │
└────────────────────────────────────────────────────────────────┘
```

#### Conceitos-chave

| Conceito | O que é | Analogia |
|----------|---------|----------|
| **Crew** | A equipe completa com todos os agentes | Time de plantão |
| **Agent** | Um membro com papel e objetivo definidos | Profissional especializado |
| **Task** | Trabalho específico atribuído a um agente | Ticket/chamado |
| **Process** | Ordem de execução (sequencial ou hierárquico) | Fluxo de trabalho do time |

#### Código simplificado

```python
from crewai import Agent, Task, Crew

investigator = Agent(
    role="SRE Investigador",
    goal="Encontrar causa raiz de incidentes",
    backstory="Você é um SRE sênior com 10 anos de experiência em K8s"
)

fixer = Agent(
    role="DevOps Engineer",
    goal="Propor fix com menor blast radius possível",
    backstory="Você é pragmático e prefere soluções simples"
)

reviewer = Agent(
    role="Security Reviewer",
    goal="Garantir que mudanças não introduzem risco",
    backstory="Você é paranóico com segurança e sempre verifica permissões"
)

# Tarefas em sequência
investigate = Task(description="Analise: {incident}", agent=investigator)
fix = Task(description="Proponha solução para o diagnóstico", agent=fixer)
review = Task(description="Valide segurança da solução proposta", agent=reviewer)

crew = Crew(agents=[investigator, fixer, reviewer], tasks=[investigate, fix, review])
crew.kickoff(inputs={"incident": "order-api latência > 2s"})
```

#### Quando faz sentido

- Workflows onde **diferentes perspectivas** precisam ser aplicadas em sequência
- Processos que no mundo real envolvem mais de uma pessoa (diagnóstico → fix → review)
- Quando a **separação de responsabilidades** melhora a qualidade do output

#### Quando NÃO faz sentido

- Tarefa simples que um agente resolve sozinho (overhead de coordenação não compensa)
- Quando você precisa de controle fino sobre cada decisão (CrewAI abstrai muito)

---

### AutoGen (Microsoft) — A mesa redonda (em detalhe)

#### O que é na prática

AutoGen modela agentes como **participantes de uma conversa**. Em vez de executar em sequência fixa, eles **dialogam livremente** — um propõe, outro questiona, outro complementa — até chegarem a uma conclusão. O humano pode entrar como mais um participante.

> **Nota 2026:** AutoGen está em modo de manutenção. A Microsoft redirecionou esforços para Semantic Kernel e Azure AI Agent Service. Incluímos aqui porque o **padrão** (debate multi-agente) permanece relevante mesmo que o framework mude.

#### Como funciona por dentro

```
┌──────────────────── GRUPO DE CONVERSA ────────────────────────┐
│                                                                │
│  Arquiteto: "Para migrar o PostgreSQL, proponho ir para RDS.  │
│              Vantagem: managed service, backup automático,      │
│              menos toil operacional."                           │
│                                                                │
│  SRE:       "Concordo com RDS, mas e o downtime? A migração   │
│              padrão com pg_dump leva ~4h para nosso volume.    │
│              SLA permite isso? Alternativa: pglogical para     │
│              replicação com zero downtime."                     │
│                                                                │
│  Arquiteto: "Boa. Com pglogical: replicação async, cutover    │
│              em segundos. Mais complexo de configurar, mas     │
│              zero downtime."                                    │
│                                                                │
│  FinOps:    "Custo: RDS db.r6g.large = $180/mês.             │
│              EC2 atual = $95/mês. Diferença de $85/mês,       │
│              mas economizamos ~16h/mês de operação.            │
│              ROI positivo em 2 meses."                          │
│                                                                │
│  SRE:       "Aceito. Proponho: pglogical → cutover em janela  │
│              de baixo tráfego (domingo 3h) → rollback plan     │
│              mantendo source por 7 dias."                       │
│                                                                │
│  Humano:    "Aprovado. Gerem o runbook."                       │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

#### Conceitos-chave

| Conceito | O que é | Analogia |
|----------|---------|----------|
| **ConversableAgent** | Agente que sabe conversar e responder | Participante de reunião |
| **GroupChat** | Espaço onde múltiplos agentes interagem | Sala de reunião |
| **UserProxy** | Agente que representa o humano | Você na reunião |
| **Speaker selection** | Quem fala na próxima rodada | Moderador escolhendo |

#### Código simplificado

```python
from autogen import ConversableAgent, GroupChat, GroupChatManager

architect = ConversableAgent(
    name="Arquiteto",
    system_message="Você propõe soluções de arquitetura para infra"
)

sre = ConversableAgent(
    name="SRE",
    system_message="Você questiona riscos operacionais e propõe mitigações"
)

finops = ConversableAgent(
    name="FinOps",
    system_message="Você analisa custos e ROI de decisões de infra"
)

human = ConversableAgent(
    name="Humano",
    human_input_mode="ALWAYS"  # sempre pede input do humano
)

chat = GroupChat(agents=[architect, sre, finops, human], max_round=10)
manager = GroupChatManager(groupchat=chat)

human.initiate_chat(manager, message="Precisamos migrar o PostgreSQL. Opções?")
```

#### Quando faz sentido

- **Decisões complexas** com trade-offs que precisam ser debatidos
- Planejamento onde múltiplas perspectivas (custo, risco, arquitetura) importam
- Quando o **humano precisa participar naturalmente** da discussão

#### Quando NÃO faz sentido

- Execução direta (AutoGen é melhor para **pensar** do que para **fazer**)
- Tarefas com resposta objetiva (overhead de "debate" não compensa)
- Cenários sensíveis a custo — cada rodada de conversa consome muitos tokens

---

## Resumo visual: quando usar cada framework

> Diagrama disponível em: `imgs/frameworks-quando-usar.png`

```
"Preciso fazer UMA coisa         "Preciso de VÁRIOS            "Preciso DECIDIR algo
 usando VÁRIAS ferramentas"       especialistas em SEQUÊNCIA"   com VÁRIAS perspectivas"
         │                                  │                              │
         ↓                                  ↓                              ↓
    ┌──────────┐                    ┌──────────┐                   ┌──────────┐
    │ LangChain│                    │  CrewAI  │                   │ AutoGen  │
    └──────────┘                    └──────────┘                   └──────────┘
    
    1 agente,                       N agentes,                     N agentes,
    N ferramentas                   N tarefas em fila              conversando livremente
```

---

## Pontos-chave

1. **Você já usa agentes** — Kiro com tool use é um agente de nível 1-2. O conceito é presente, não futuro.
2. **Framework ≠ necessidade** — Para maioria dos casos em infra, shell + LLM resolve. Frameworks são para orquestração multi-sistema.
3. **Autonomia gradual é o caminho seguro** — Nunca pular de nível 0 para nível 3. Evoluir com evidência.
4. **Custo é real** — Multi-agente = muitos tokens. Um "debate" entre 3 agentes pode custar 10x um prompt direto.
5. **O mercado está convergindo** — Em 1-2 anos, as fronteiras entre esses frameworks vão borrar. O importante é entender os padrões, não se casar com uma ferramenta.
6. **Frameworks vêm e vão, padrões ficam** — AutoGen já está em manutenção. LangChain virou LangGraph. O padrão (agente único, time sequencial, debate) sobrevive à ferramenta.
