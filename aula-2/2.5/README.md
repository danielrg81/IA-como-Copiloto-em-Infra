# Aula 2.5 — Criando uma Biblioteca Pessoal de Prompts Operacionais

## Estrutura da biblioteca

```
prompts/
├── troubleshooting/
│   ├── crashloopbackoff.md
│   ├── oom-killed.md
│   └── dns-resolution.md
├── geracao/
│   ├── helm-chart.md
│   ├── kubernetes-deployment.md
│   ├── dockerfile.md
│   └── runbook.md
└── analise/
    ├── logs-performance.md
    ├── logs-correlacao.md
    ├── correlacao-metricas.md
    └── metricas-anomalia.md
```

## Anatomia de um prompt na biblioteca

Cada arquivo segue a estrutura:

```
# Nome do prompt
## Descrição — quando usar
## Template — o prompt com {{VARIÁVEIS}}
## Variáveis — tabela com descrição e exemplo
## Exemplo de uso — comando copy-paste pronto
```

## Conceito: "Prompt como código"

| Princípio | Aplicação |
|---|---|
| Versionar | Git — ver evolução, quem mudou, por quê |
| Categorizar | Por caso de uso (troubleshooting, geração, análise) |
| Documentar variáveis | Quem nunca usou sabe preencher |
| Incluir exemplo | Copy-paste pronto reduz fricção |
| Revisar | PR review de prompts — igual a código |
