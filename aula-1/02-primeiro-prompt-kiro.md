# Primeiro contato com Kiro CLI

## O que é o Kiro CLI

Kiro é um assistente de IA de linha de comando. Ele lê arquivos, executa comandos, e ajuda com tarefas de infraestrutura direto no terminal.

## Configuração

```bash
# Autenticar (primeira vez)
kiro auth
```

## Exercício 1 — Primeiro prompt simples

```bash
kiro chat "Quais pods estão rodando no meu cluster k3s? Liste os namespaces."
```

Observe: o Kiro pode executar `kubectl get pods -A` por você e interpretar o resultado.

## Exercício 2 — Pedir explicação de um recurso

```bash
kiro chat "Explique o que é o Traefik que está rodando no meu k3s e para que serve."
```

## Exercício 3 — Gerar um recurso simples

```bash
kiro chat "Crie um namespace chamado ai-iac-lab no meu k3s."
```

## Exercício 4 — Diagnóstico rápido

```bash
kiro chat "Verifique se todos os pods do kube-system estão saudáveis e me diga se há algum problema."
```

## Exercício 5 — Pedir ajuda com um comando

```bash
kiro chat "Qual o comando kubectl para ver os logs dos últimos 5 minutos do pod do traefik?"
```

## O que observar

- O Kiro entende contexto do seu ambiente (lê arquivos, executa comandos)
- Respostas são específicas para o que está rodando na sua máquina
- Diferente de um chatbot genérico: ele age, não só responde
