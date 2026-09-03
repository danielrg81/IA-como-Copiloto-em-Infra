# Prompt: Geração de Runbook Operacional

## Descrição
Gerar runbook operacional a partir de um procedimento descrito informalmente ou de um incidente resolvido.

## Template

```
Papel: Você é um SRE senior que documenta procedimentos operacionais.

Contexto:
- Ambiente: {{ENVIRONMENT}}
- Serviço: {{SERVICE_NAME}}
- Cenário: {{SCENARIO}}

Instrução: Gere um runbook operacional completo baseado nas informações abaixo.

Informações do procedimento:
{{PROCEDURE_DESCRIPTION}}

O runbook deve conter:
1. Título e descrição do cenário
2. Pré-requisitos (acessos, ferramentas)
3. Sintomas / como identificar o problema
4. Passos de resolução (comandos exatos, copy-paste ready)
5. Validação (como confirmar que resolveu)
6. Rollback (se a ação piorar)
7. Escalação (quando escalar e para quem)

Restrições:
- Comandos devem ser específicos para k3s (kubectl, helm)
- Incluir output esperado de cada comando
- Linguagem clara para qualquer nível de experiência
- Formato Markdown

Formato de saída: Runbook completo em Markdown.
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| ENVIRONMENT | Ambiente | k3s single-node |
| SERVICE_NAME | Serviço afetado | order-api |
| SCENARIO | Cenário do problema | pod em CrashLoopBackOff |
| PROCEDURE_DESCRIPTION | Descrição do procedimento | ver exemplo abaixo |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: SRE senior que documenta procedimentos operacionais.

Contexto:
- Ambiente: k3s single-node
- Serviço: order-api
- Cenário: pod em CrashLoopBackOff por falha de conexão com banco

Informações: O pod order-api não consegue conectar no postgres porque o Service do banco não existe no namespace. A solução é verificar se o postgres está rodando, criar o Service se necessário, e reiniciar o pod.

Gere um runbook com:
1. Título e descrição
2. Pré-requisitos
3. Sintomas
4. Passos de resolução (comandos exatos)
5. Validação
6. Rollback
7. Escalação

Formato: Markdown, comandos copy-paste ready para k3s."
```
