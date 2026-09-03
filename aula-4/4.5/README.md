# 4.5 — Governanca corporativa de IA: estruturando um modelo para a empresa

## Contexto

O diretor de tecnologia leu que a partir de agosto de 2026 o EU AI Act entra em vigor com multas de ate 7% do faturamento global. O CISO quer saber quais controles existem sobre o uso de IA nos times de operacoes. O gestor de infra precisa responder: "temos governanca de IA ou cada time usa como quer?"

A resposta honesta hoje, na maioria das empresas: cada time usa como quer. Alguns usam IA para tudo sem review. Outros proibem por medo. Nao existe politica, nao existe inventario de usos, nao existe metrica. A empresa tem 50 pessoas usando IA diariamente e zero visibilidade de como.

Isso nao e sustentavel. E a boa noticia e que nao precisa comecar do zero — as grandes clouds ja publicaram frameworks de referencia que servem como ponto de partida.

## Problema

Sem governanca corporativa de IA:
- **Risco regulatorio** — leis como EU AI Act e normas como ISO 42001 exigem controles documentados
- **Risco operacional** — codigo gerado por IA vai para producao sem validacao adequada
- **Inconsistencia** — cada time define suas proprias regras (ou nenhuma)
- **Impossibilidade de auditoria** — sem registro de onde e como IA esta sendo usada

## Teoria

### O que e governanca de IA

Governanca de IA e o conjunto de politicas, processos e controles que definem:
- **Onde** a IA pode ser usada
- **Como** deve ser validada
- **Quem** e responsavel pelo output
- **Como** medir se esta funcionando

Nao e burocracia. E gestao de risco proporcional — as mesmas praticas que ja aplicamos para seguranca, compliance e change management, adaptadas para o contexto de IA.

---

### Frameworks de referencia das clouds publicas

Para quem esta iniciando, os 3 grandes cloud providers oferecem frameworks gratuitos, praticos e bem documentados:

#### AWS — Well-Architected Responsible AI Lens

**O que e:** Uma extensao do AWS Well-Architected Framework focada em IA responsavel. Organiza controles ao longo do ciclo de vida da IA.

**Estrutura:**
```
┌─────────────────────────────────────────────────────┐
│          AWS Responsible AI Framework               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. GOVERNANCA        Politicas, papeis, comite     │
│  2. DATA GOVERNANCE   Qualidade, privacidade        │
│  3. MODELO            Avaliacao, teste, validacao   │
│  4. MONITORAMENTO     Drift, bias, performance     │
│  5. HUMANO NO LOOP    Aprovacoes, escalacao         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Por que usar:** Integra com o modelo de Well-Architected Reviews que muitas empresas ja adotam. Abordagem de risco baseada em use cases.

**Referencia:** aws.amazon.com/ai/responsible-ai/

---

#### Microsoft — Responsible AI Standard + Cloud Adoption Framework

**O que e:** Framework baseado em 6 principios, com guia pratico de implementacao via Cloud Adoption Framework (CAF).

**Os 6 principios:**
```
┌─────────────────────────────────────────────────────┐
│       Microsoft Responsible AI Standard             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. FAIRNESS          Evitar bias e discriminacao   │
│  2. RELIABILITY       Funcionamento previsivel      │
│  3. PRIVACY           Protecao de dados             │
│  4. INCLUSIVENESS     Acessibilidade                │
│  5. TRANSPARENCY      Explicabilidade               │
│  6. ACCOUNTABILITY    Responsabilidade definida     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Por que usar:** O Cloud Adoption Framework traduz principios em acoes concretas: criar comite, classificar riscos, implementar gates no pipeline. Muito pratico para quem ja usa Azure.

**Referencia:** learn.microsoft.com/azure/cloud-adoption-framework/ai/govern

---

#### Google Cloud — Secure AI Framework (SAIF) + Recommended AI Controls

**O que e:** Framework com foco em seguranca de sistemas de IA, organizado em camadas de controle.

**Estrutura em 5 camadas (para agentes):**
```
┌─────────────────────────────────────────────────────┐
│        Google Cloud AI Governance Stack             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. IDENTIDADE        Cada agente com ID unico      │
│  2. ACESSO            Menor privilegio (RBAC)       │
│  3. DADOS             Classificacao e protecao      │
│  4. MODELO            Avaliacao e monitoramento     │
│  5. AUDITORIA         Registro de todas as acoes    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Por que usar:** Foco forte em seguranca — ideal para times de infra/SRE. O "Recommended AI Controls" mapeia diretamente para auditorias.

**Referencia:** cloud.google.com/responsible-ai

---

### O que os 3 frameworks tem em comum

Independente do provider, todos convergem nos mesmos pilares:

| Pilar | AWS | Microsoft | Google |
|-------|-----|-----------|--------|
| Responsabilidade definida | Governanca | Accountability | Auditoria |
| Classificacao de risco | Use case assessment | Risk classification | Classificacao de dados |
| Humano no loop | Human oversight | Reliability | Controle de acesso |
| Monitoramento | Drift/performance | Transparency | Monitoramento de modelo |
| Menor privilegio | IAM scoped | RBAC | Identidade + acesso |

**Conclusao:** Nao importa qual cloud voce usa. Os principios sao os mesmos. Escolha o framework do seu provider principal como ponto de partida e adapte.

---

### Como estruturar governanca na sua empresa (5 passos)

#### Passo 1: Inventario — o que ja existe

Antes de criar politicas, descubra o que ja esta acontecendo:
- Quais times usam IA?
- Para quais tarefas?
- Quais ferramentas (Copilot, ChatGPT, Kiro, Gemini)?
- O output vai para producao?

**Entregavel:** Mapa de uso de IA por time/ferramenta/risco.

#### Passo 2: Classificacao de risco por use case

Nem todo uso de IA tem o mesmo risco. Classificar permite regras proporcionais:

| Nivel | Uso | Risco | Controle |
|-------|-----|-------|----------|
| Baixo | Documentacao, explicacao, estudo | Nenhum impacto em producao | Uso livre |
| Medio | Codigo para staging, troubleshooting dev | Impacto limitado | Review + CI |
| Alto | Codigo para producao, seguranca, RBAC | Impacto em clientes | Review + CI + aprovacao security |
| Critico | Agentes autonomos, auto-remediacao prod | Acao automatica em producao | Todas as camadas + comite |

#### Passo 3: Definir papeis e responsabilidades

| Papel | Responsabilidade |
|-------|-----------------|
| **Desenvolvedor/SRE** | Validar output da IA antes de merge |
| **Reviewer** | Verificar checklist de seguranca e valores |
| **Tech Lead** | Definir quais use cases sao nivel alto/critico |
| **CISO/Security** | Aprovar use cases criticos, definir politicas |
| **Comite de IA** | Revisar metricas trimestrais, ajustar politicas |

**Regra de ouro:** Quem faz merge e responsavel pelo codigo — independente de quem ou o que gerou.

#### Passo 4: Implementar controles no pipeline

Politica sem enforcement e lista de desejo. Automatizar no CI:

```
PR aberto
    |
    v
[CI Step 1] terraform validate / helm lint         → bloqueante
[CI Step 2] scanner de secrets (truffleHog, etc)   → bloqueante
[CI Step 3] lint de imagens (sem :latest)          → bloqueante
[CI Step 4] policy check (OPA/Kyverno)             → bloqueante
[CI Step 5] terraform plan (output no PR)          → informativo
    |
    v
[Review humano] valida plan + valores + RBAC
    |
    v
Merge
```

#### Passo 5: Medir e iterar

| Metrica | O que indica | Meta |
|---------|-------------|------|
| Tempo de entrega | Produtividade | Reduzir 30-50% |
| Incidentes com IA | Risco | Zero |
| Taxa de adocao | Confianca do time | >70% |
| Rollbacks pos-deploy | Qualidade | Nao aumentar |
| Findings em review | Qualidade do output | Reduzir ao longo do tempo |

Revisar trimestralmente. Se metricas melhoram, expandir autonomia. Se pioram, restringir e investigar.

---

### Modelo de maturidade: confianca gradual

```
  FASE 1               FASE 2                  FASE 3
  EXPLORAR        →    PADRONIZAR         →    ESCALAR
  (1-2 meses)          (3-4 meses)             (5+ meses)

• Inventario de uso    • Politica formal       • IA integrada ao
• Baseline metricas    • CI com gates            fluxo padrao
• Zonas de risco       • Treinamento time      • Metricas automaticas
  definidas            • PR template           • Comite trimestral
• Uso restrito a       • Review obrigatorio    • Confianca gradual
  low-risk               para high-risk          baseada em evidencia
```

**Criterio para avancar:** Zero incidentes causados por IA no periodo anterior + metricas de produtividade estáveis ou melhorando.

---

### Artefatos minimos de governanca

Para comecar HOJE, uma empresa precisa de 3 documentos:

1. **Politica de uso de IA** — 1-2 paginas definindo zonas, responsabilidades e excecoes
2. **Checklist no CI** — Steps automatizados que bloqueiam PR non-compliant
3. **PR Template** — Forca declaracao de uso de IA e zona de risco

Tudo o mais (comite, metricas avancadas, auditoria formal) pode vir depois. Esses 3 artefatos ja resolvem 80% do problema.

---

## Pontos-chave

1. **Comece pelo inventario** — Antes de criar politicas, descubra o que ja esta acontecendo. Nao da para governar o que voce nao enxerga.
2. **Use o framework do seu cloud provider** — AWS, Microsoft e Google publicam guias gratuitos e praticos. Nao reinvente a roda.
3. **Risco proporcional** — Documentacao e uso livre. Producao e review obrigatorio. Tratar tudo igual trava o time ou expoe a empresa.
4. **Politica sem CI e wishlist** — Se nao esta automatizado como step bloqueante, ninguem segue sob pressao de deadline.
5. **Quem mergeia, e dono** — IA e ferramenta. Responsabilidade e sempre humana. Isso nao e punicao, e clareza.
6. **Medir antes de expandir** — Sem baseline de metricas, nao da para saber se IA esta ajudando ou criando risco. Evidencia > hype.
