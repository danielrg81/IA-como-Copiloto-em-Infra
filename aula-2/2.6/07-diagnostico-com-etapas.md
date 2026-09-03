# Exercício 7 — Diagnóstico com etapas narradas

## Objetivo
Usar etapas específicas de troubleshooting para tornar o raciocínio da IA visível durante análise de incidente.

## Kiro CLI

```bash
kiro chat "Narre seu raciocínio em etapas:
[INTERPRETANDO] → o que os logs indicam
[CORRELACIONANDO] → padrões e cadeia de causa/efeito
[DIAGNOSTICANDO] → causa raiz
[PRESCREVENDO] → ações para resolver

Pod order-api em CrashLoopBackOff. Diagnostique:

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Quero: causa raiz + 3 ações priorizadas + comando exato para cada ação."
```

## Gemini CLI

```bash
gemini "Narre seu raciocínio em etapas:
[INTERPRETANDO] → o que os logs indicam
[CORRELACIONANDO] → padrões e cadeia de causa/efeito
[DIAGNOSTICANDO] → causa raiz
[PRESCREVENDO] → ações para resolver

Pod order-api em CrashLoopBackOff. Diagnostique:

Logs:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/crashloop.log)

Quero: causa raiz + 3 ações priorizadas + comando exato para cada ação."
```

## Tabela de comparação

| Critério | Kiro CLI | Gemini CLI |
|----------|----------|------------|
| [INTERPRETANDO] extraiu os dados certos dos logs? | | |
| [CORRELACIONANDO] montou a cadeia corretamente? | | |
| [DIAGNOSTICANDO] acertou a causa raiz? | | |
| [PRESCREVENDO] deu comandos exatos e corretos? | | |
| A narração ajudou a identificar onde a IA errou? | | |

## Por que isso importa

Ao pedir etapas narradas, você consegue:
- Identificar **onde** a IA errou (interpretou mal? correlacionou errado? prescreveu comando incorreto?)
- Dar feedback mais preciso ("sua interpretação está certa mas a correlação está errada")
- Entender se vale a pena iterar ou recomeçar do zero
