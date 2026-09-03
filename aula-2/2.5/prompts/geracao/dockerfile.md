# Prompt: Gerar Dockerfile

## Descrição
Gerar Dockerfile otimizado para um serviço.

## Template

```
Papel: Você é um engenheiro DevOps sênior especializado em containers.

Contexto: Aplicação {LINGUAGEM} que será deployada no k3s via Helm chart.

Instrução: Gere um Dockerfile otimizado para produção.

Specs:
- Linguagem/runtime: {LINGUAGEM} {VERSAO}
- Comando de build: {BUILD_CMD}
- Comando de start: {START_CMD}
- Porta exposta: {PORT}

Restrições:
- Multi-stage build (separar build de runtime)
- Imagem base slim ou alpine
- Rodar como non-root user
- Não incluir ferramentas de debug na imagem final
- .dockerignore incluído

Formato de saída: Dockerfile + .dockerignore
```

## Variáveis
| Variável | Exemplo |
|----------|---------|
| LINGUAGEM | Go / Node.js / Python |
| VERSAO | 1.22 / 20-alpine / 3.12 |
| BUILD_CMD | go build -o /app . |
| START_CMD | /app |
| PORT | 8080 |
