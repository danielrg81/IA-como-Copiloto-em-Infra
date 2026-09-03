# Demo — Usar um prompt da biblioteca

## Objetivo
Mostrar como pegar um template da biblioteca, preencher as variáveis e usar.

## Passo 1: Ver o template

```bash
cat ~/ai-iac-labs/aula-2/prompts/troubleshooting/oom-killed.md
```

## Passo 2: Preencher e enviar

```bash
kiro chat "Papel: SRE senior especializado em troubleshooting de memória em Kubernetes.

Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod email-worker terminado com OOMKilled
Resource limits: memory=128Mi
Último restart: 2 min atrás

Logs antes do OOM:
$(cat ~/ai-iac-labs/aula-2/logs-simulados/oom-killed.log)

Informações:
- Workload: worker processando fila de emails
- Runtime: Node.js 18
- Padrão: processa jobs em batch, cada job pode ter N anexos

O que já tentei:
- Aumentar limit para 256Mi (voltou a crashar após 5 min)

1. O que está causando o consumo excessivo?
2. Devo aumentar limit ou corrigir configuração?
3. Quais métricas monitorar?

Formato: análise em bullet points + recomendação final."
```

## O que observar
- O template deu estrutura suficiente para resposta precisa?
- A IA pediu mais informação ou respondeu direto?
- A resposta é acionável (comandos concretos)?
