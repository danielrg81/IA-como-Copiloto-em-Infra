# Exercício 6 — Iteração com etapas narradas

## Objetivo
Testar memória e iteração pedindo que a IA narre suas etapas em cada prompt progressivo.

## Prompt 1

```
Indique suas etapas de raciocínio entre colchetes: [INTERPRETANDO], [PLANEJANDO], [GERANDO], [REVISANDO].

Gere um Deployment nginx básico com 1 replica no namespace ai-iac-lab.
```

## Prompt 2

```
Mesma estrutura de etapas. Agora adicione um HPA com target de 70% de CPU, min 1 e max 5 replicas.
```

## Prompt 3

```
Mesma estrutura de etapas. Tem algum problema de segurança no que você gerou até agora?
```

## Tabela de comparação

| Pergunta | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| No prompt 2, [INTERPRETANDO] menciona o deployment anterior? | | |
| No prompt 3, [CORRELACIONANDO] conecta os recursos gerados? | | |
| A narração de etapas melhorou a qualidade da resposta? | | |
| Alguma ferramenta "pulou" etapas? | | |
