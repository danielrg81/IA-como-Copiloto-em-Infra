# Aula 4 — Agentic Workflows e Limites da IA

## Objetivo

Entender o que são agentes, onde o mercado está, quais os riscos reais de usar IA em infraestrutura, e como construir uma cultura de uso responsável com governança prática.

## Natureza da aula

Esta é uma **aula teórica com exemplos práticos**. Não há scripts para executar — o foco está em:
- Construir modelo mental claro sobre agentes vs. chatbots
- Conhecer o ecossistema de frameworks
- Identificar e defender contra alucinações
- Definir proteções proporcionais ao risco
- Criar artefatos de governança para o time

## Temas

| Tema | Subtópico | O que cobre |
|------|-----------|-------------|
| 4.1 | Chatbots vs. Agentes | Loop de decisão, tool use, diferença de risco |
| 4.2 | Mercado de agentes | LangChain, CrewAI, AutoGen, autonomia gradual |
| 4.3 | Alucinações em IaC | Tipos, exemplos, pipeline de defesa, checklist |
| 4.4 | Blast radius e guardrails | 5 camadas de proteção, menor privilégio |
| 4.5 | Governança no time | Zonas de uso, responsabilidade, métricas |

## Estrutura

```
aula-4/
├── README.md               ← Este arquivo
├── 4.1/README.md           ← Chatbots vs. Agentes
├── 4.2/README.md           ← Mercado de agentes e frameworks
├── 4.3/README.md           ← Alucinações em IaC
├── 4.4/README.md           ← Blast radius e guardrails
└── 4.5/README.md           ← Governança e cultura responsável
```

## Fio condutor (storytelling)

A aula segue a jornada de um time que está adotando IA:

1. **4.1** — O time descobre que já usa agentes (Kiro com tool use) e entende a diferença de risco
2. **4.2** — O gestor pergunta "e se automatizarmos mais?" — exploramos o que existe e o que é viável
3. **4.3** — Um incidente acontece: a IA gerou código com alucinação. Como evitar na próxima vez?
4. **4.4** — O time define camadas de proteção proporcionais ao risco de cada ação
5. **4.5** — Com tudo definido, o time formaliza política, checklist e métricas para uso sustentável

## Pré-requisitos

- Ter completado as aulas 1-3 (entender o contexto prático)
- Familiaridade com Kiro CLI e Gemini CLI
- Entender terraform plan/apply e helm install/upgrade
