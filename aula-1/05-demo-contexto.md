# Demonstração: Janela de Contexto e Tokens

## Conceito

LLMs processam texto em **tokens** (pedaços de ~4 caracteres). A **janela de contexto** é o limite de tokens que o modelo consegue "ver" de uma vez.

- Prompt + resposta precisam caber na janela
- Informação fora da janela é "esquecida"
- Mais contexto relevante = melhor resposta

## Experimento 1: Sem contexto vs. com contexto

### Sem contexto:
```bash
kiro chat "Por que meu pod está falhando?"
```
Resposta: genérica, lista 10 possíveis causas sem saber qual se aplica.

### Com contexto:
```bash
kiro chat "Meu pod order-api no namespace ai-iac-lab está em CrashLoopBackOff.
A imagem é postgres:15, as envs são PGHOST=localhost PGPORT=5432.
Não existe nenhum Service de postgres no namespace.
Por que está falhando?"
```
Resposta: específica, aponta exatamente o problema.

## Experimento 2: Contexto demais dilui

### Prompt com ruído:
```bash
kiro chat "Estou com um problema no meu cluster. Ontem eu instalei o k3s, depois configurei o helm, aí criei uns namespaces, testei umas coisas, fui almoçar, voltei, criei mais uns pods, um deles é o order-api que usa postgres, aí ele começou a dar erro, eu tentei reiniciar mas não funcionou, aí fui ver os logs e tinha connection refused, aí tentei criar um service mas errei o nome, aí deletei e tentei de novo. O que está errado?"
```

### Prompt focado (mesma informação útil):
```bash
kiro chat "Pod order-api em CrashLoopBackOff.
Log: connection refused localhost:5432.
Não existe Service postgres no namespace.
Causa e solução?"
```

## Experimento 3: Tokens na prática

```bash
# Ver quantos tokens um arquivo tem (aproximação: palavras * 1.3)
wc -w ~/ai-iac-labs/aula-2/logs-simulados/slow-response.log
# ~120 palavras ≈ 156 tokens — cabe tranquilo

# Um log de 5000 linhas:
# ~5000 palavras ≈ 6500 tokens — pode ser muito, filtrar antes
```

### Regra prática para infra:
```bash
# Filtrar ANTES de enviar
kubectl logs meu-pod --since=5m | grep -i error | tail -20
# Enviar só o relevante, não o log inteiro
```

## Lições

| Princípio | Aplicação em Infra |
|---|---|
| Mais contexto relevante = melhor resposta | Incluir namespace, imagem, envs, o que já tentou |
| Contexto irrelevante = ruído | Não contar a história do dia, ir direto ao ponto |
| Janela tem limite | Filtrar logs antes de enviar |
| Modelo não tem memória entre sessões | Cada prompt precisa ser auto-contido |
