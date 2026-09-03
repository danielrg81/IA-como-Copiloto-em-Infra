# Prompt: Gerar Dockerfile

## Descrição
Gerar Dockerfile otimizado para produção.

## Template

```
Papel: Você é um engenheiro DevOps sênior especializado em containers.

Contexto: Aplicação {{LINGUAGEM}} que será deployada no k3s via Helm chart.

Instrução: Gere um Dockerfile otimizado para produção.

Specs:
- Linguagem/runtime: {{LINGUAGEM}} {{VERSAO}}
- Comando de build: {{BUILD_CMD}}
- Comando de start: {{START_CMD}}
- Porta exposta: {{PORT}}

Restrições:
- Multi-stage build (separar build de runtime)
- Imagem base slim ou alpine
- Rodar como non-root user
- Não incluir ferramentas de debug na imagem final
- .dockerignore incluído

Formato de saída: Dockerfile + .dockerignore
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| LINGUAGEM | Linguagem/runtime | Go / Node.js / Python |
| VERSAO | Versão | 1.22 / 20-alpine / 3.12 |
| BUILD_CMD | Comando de build | go build -o /app . |
| START_CMD | Comando de start | /app |
| PORT | Porta exposta | 8080 |

## Exemplo de uso com Kiro CLI

```bash
kiro chat "Papel: Engenheiro DevOps sênior especializado em containers.

Contexto: Aplicação Go que será deployada no k3s.

Gere um Dockerfile otimizado:
- Runtime: Go 1.22
- Build: go build -o /app .
- Start: /app
- Porta: 8080

Restrições: Multi-stage, alpine, non-root, sem ferramentas de debug.
Formato: Dockerfile + .dockerignore"
```
