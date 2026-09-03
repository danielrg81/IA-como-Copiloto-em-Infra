# Roteiro de Falas — Aula 4.5: Governanca Corporativa de IA

## Tempo estimado: 12-15 minutos

---

## Abertura (2 min)

> Ate aqui neste modulo, falamos de protecoes tecnicas: detectar alucinacoes, calcular blast radius, implementar guardrails. Tudo isso funciona no nivel do time — do desenvolvedor e do SRE.

> Mas agora vamos subir um nivel. O diretor de tecnologia pergunta: "temos governanca de IA na empresa ou cada time usa como quer?" O CISO quer saber quais controles existem. O compliance precisa responder a auditoria.

> E a resposta honesta hoje, na maioria das empresas, e: cada time usa como quer. 50 pessoas usando IA diariamente, zero visibilidade de como, zero politica formal, zero metrica.

> Isso nao e sustentavel. Regulacoes como o EU AI Act ja estao em vigor com multas de ate 7% do faturamento global. ISO 42001 ja e certificavel. Nao e mais questao de "se" a empresa vai precisar de governanca de IA — e "quando". E a resposta e: agora.

> A boa noticia: nao precisa comecar do zero. As grandes clouds ja publicaram frameworks de referencia que servem como ponto de partida. Vamos ver quais sao e como usar.

---

## Frameworks de referencia (3 min)

> Quando a gente fala de governanca de IA para quem esta comecando, eu recomendo olhar primeiro para os frameworks das clouds publicas. Por que? Porque sao gratuitos, praticos, bem documentados, e provavelmente voces ja usam algum desses providers.

### AWS — Well-Architected Responsible AI Lens

> A AWS estendeu o Well-Architected Framework — que muitas empresas ja usam para revisar arquitetura — com uma "lens" especifica para IA responsavel. Ela organiza controles ao longo do ciclo de vida: governanca, dados, modelo, monitoramento e humano no loop.

> Se a empresa ja faz Well-Architected Reviews, adicionar a AI Lens e natural. Nao e um processo novo — e uma extensao do que ja existe.

### Microsoft — Responsible AI Standard + Cloud Adoption Framework

> A Microsoft definiu 6 principios: fairness, reliability, privacy, inclusiveness, transparency e accountability. Mas o que faz esse framework ser pratico e o Cloud Adoption Framework — ele traduz os principios em acoes concretas: criar comite, classificar riscos, implementar gates no pipeline.

> Se a empresa usa Azure, o CAF ja tem o caminho desenhado: estrategia, governanca, seguranca, tudo integrado.

### Google Cloud — SAIF + Recommended AI Controls

> O Google publicou o Secure AI Framework e recentemente o "Recommended AI Controls" — um framework de controles mapeados para auditoria. A estrutura e em 5 camadas: identidade do agente, acesso, dados, modelo e auditoria.

> Foco forte em seguranca — ideal para times de infra e SRE. Cada controle mapeia diretamente para evidencia de auditoria.

### O que os 3 tem em comum

> Independente do provider, todos convergem nos mesmos pilares: responsabilidade definida, classificacao de risco, humano no loop, monitoramento continuo e menor privilegio.

> A minha recomendacao: escolha o framework do provider que voces ja usam. Nao reinvente a roda. Adapte ao contexto da empresa.

---

## Como estruturar na pratica (4 min)

> Ok, escolhi um framework de referencia. E agora? Como transformar isso em algo concreto na empresa? 5 passos:

### Passo 1: Inventario

> Antes de criar politicas, descubra o que ja esta acontecendo. Quais times usam IA? Para quais tarefas? O output vai para producao? Quais ferramentas?

> Nao da para governar o que voce nao enxerga. Entregavel: um mapa simples de uso por time, ferramenta e nivel de risco.

### Passo 2: Classificar risco por use case

> Nem todo uso tem o mesmo risco. Documentacao e risco baixo — uso livre. Codigo para producao e risco alto — review obrigatorio. Agentes autonomos em prod e risco critico — todas as camadas.

> Regras proporcionais. Nao trave o time com burocracia para tarefas de risco baixo. E nao deixe tarefas de risco alto passarem sem controle.

### Passo 3: Definir papeis

> Quem e responsavel pelo que? O desenvolvedor valida antes do merge. O reviewer verifica seguranca. O tech lead classifica os use cases. O CISO aprova os criticos.

> E a regra de ouro: quem faz merge e dono do codigo. Nao importa se foi a IA que gerou.

### Passo 4: Automatizar no CI

> Politica sem enforcement e lista de desejo. Ninguem segue politica sob pressao de deadline se nao tem um gate automatico bloqueando.

> terraform validate, scanner de secrets, lint de imagens, policy check com OPA — tudo automatizado, tudo bloqueante. O plan aparece como comentario no PR para o reviewer humano validar.

### Passo 5: Medir e iterar

> Tempo de entrega, incidentes com IA, taxa de adocao, rollbacks. Revisar trimestralmente. Se as metricas melhoram, expandir. Se pioram, investigar e restringir.

---

## Modelo de maturidade (2 min)

> Nao adotar tudo de uma vez. Evoluir em fases:

> **Fase 1 — Explorar (1-2 meses):** Fazer o inventario, definir zonas de risco, estabelecer baseline de metricas. Uso restrito a low-risk.

> **Fase 2 — Padronizar (3-4 meses):** Politica formal publicada. CI com gates automaticos. PR template. Review obrigatorio para high-risk. Treinamento do time.

> **Fase 3 — Escalar (5+ meses):** IA integrada ao fluxo padrao. Metricas automaticas. Comite trimestral. Confianca gradual baseada em evidencia.

> Criterio para avancar de fase: zero incidentes causados por IA no periodo anterior. Se acontecer um, volta uma fase e investiga. A evidencia decide, nao o calendario.

---

## Artefatos minimos (2 min)

> Para comecar HOJE, uma empresa precisa de 3 coisas:

> **1. Politica de uso** — 1 a 2 paginas. Zonas de risco, responsabilidades, excecoes. Nao precisa ser um documento de 50 paginas. Curto, claro, acionavel.

> [Mostrar demos/CONTRIBUTING.md como exemplo]

> **2. Checklist no CI** — Steps automatizados que bloqueiam PR non-compliant. Sem isso, a politica e sugestao.

> **3. PR Template** — Forca o autor a declarar se usou IA, qual zona de risco, e se passou no checklist.

> [Mostrar demos/PULL_REQUEST_TEMPLATE.md como exemplo]

> Tudo o mais — comite formal, metricas avancadas, auditoria externa — pode vir depois. Esses 3 artefatos resolvem 80% do problema e cabem em uma sprint.

---

## Fechamento da aula 4 (1 min)

> Vamos recapitular a jornada desta aula:

> Na 4.1, vimos que ja usamos agentes — e que agentes trazem risco diferente de chatbots.

> Na 4.2, mapeamos o mercado de frameworks: LangChain, CrewAI, AutoGen.

> Na 4.3, vimos que a IA alucina — e aprendemos a detectar com validacoes em camadas.

> Na 4.4, definimos blast radius e construimos 5 camadas de guardrails.

> E agora, na 4.5, subimos de nivel: governanca corporativa. Frameworks de referencia da AWS, Microsoft e Google. 5 passos para estruturar. Modelo de maturidade gradual.

> O profissional que sai desta aula sabe nao so USAR IA para IaC, mas sabe DEFENDER pro gestor por que precisa de governanca, sabe APONTAR os frameworks de referencia, e sabe IMPLEMENTAR os controles minimos numa sprint.

---

## Notas para o instrutor

- **Frameworks:** Nao se aprofundar demais em nenhum — o objetivo e que o aluno saiba que existem e onde encontrar. Deixar o link como referencia.
- **CONTRIBUTING.md:** Abrir e percorrer. O aluno vai adaptar pro time dele.
- **PR Template:** Se possivel, mostrar no GitHub como aparece ao abrir um PR real.
- **Tom:** Aula de fechamento. Tom de empoderamento — "voces tem tudo que precisam para comecar".
- **Exercicio sugerido:** Pedir pro aluno montar o inventario de uso de IA do time dele (passo 1) e classificar por zona de risco (passo 2). E o entregavel mais valioso.
- **Cuidado:** Nao transformar em aula de compliance. O foco e pratico — "como comecar na segunda-feira" — nao teorico-juridico.
