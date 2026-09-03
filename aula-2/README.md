# Aula 2 — Labs de Prompt Engineering para Operações

## Estrutura

```
aula-2/
├── [EXERCICIO-PRATICO.md](EXERCICIO-PRATICO.md)       # Exercício guiado passo a passo
├── [EXERCICIO-COMPARATIVO.md](EXERCICIO-COMPARATIVO.md)   # Comparativo Kiro vs Gemini
├── [exemplos-comparativos/](exemplos-comparativos/)     # Prompts ruins vs. bons lado a lado
│   ├── [01-prompt-ruim-vs-bom.md](exemplos-comparativos/01-prompt-ruim-vs-bom.md)
│   ├── [02-troubleshooting-estruturado.md](exemplos-comparativos/02-troubleshooting-estruturado.md)
│   └── [03-analise-logs-preprocessado.md](exemplos-comparativos/03-analise-logs-preprocessado.md)
├── [logs-simulados/](logs-simulados/)            # Logs para praticar análise com IA
│   ├── [crashloop.log](logs-simulados/crashloop.log)
│   ├── [oom-killed.log](logs-simulados/oom-killed.log)
│   └── [slow-response.log](logs-simulados/slow-response.log)
└── [prompts/](prompts/)                   # Biblioteca de prompts operacionais
    ├── [troubleshooting/](prompts/troubleshooting/)
    │   ├── [crashloopbackoff.md](prompts/troubleshooting/crashloopbackoff.md)
    │   └── [oom-killed.md](prompts/troubleshooting/oom-killed.md)
    ├── [geracao/](prompts/geracao/)
    │   ├── [dockerfile.md](prompts/geracao/dockerfile.md)
    │   ├── [helm-chart.md](prompts/geracao/helm-chart.md)
    │   ├── [kubernetes-deployment.md](prompts/geracao/kubernetes-deployment.md)
    │   └── [runbook.md](prompts/geracao/runbook.md)
    └── [analise/](prompts/analise/)
        ├── [logs-performance.md](prompts/analise/logs-performance.md)
        ├── [logs-correlacao.md](prompts/analise/logs-correlacao.md)
        ├── [correlacao-metricas.md](prompts/analise/correlacao-metricas.md)
        └── [metricas-anomalia.md](prompts/analise/metricas-anomalia.md)
```

## Como usar

1. Comece pelo [EXERCICIO-PRATICO.md](EXERCICIO-PRATICO.md) — é o guia passo a passo da aula
2. Faça o [EXERCICIO-COMPARATIVO.md](EXERCICIO-COMPARATIVO.md) para ver a diferença entre as IAs
3. Leia os [exemplos-comparativos/](exemplos-comparativos/) para entender a diferença entre prompts ruins e bons
4. Use os [logs-simulados/](logs-simulados/) para praticar análise com IA no terminal
5. Use a [prompts/](prompts/) como biblioteca de templates — copie, preencha as variáveis, envie para o Kiro CLI

## Pré-requisitos

- k3s rodando (`kubectl get nodes` retorna Ready)
- Kiro CLI configurado (`kiro auth`)
- Namespace ai-iac-lab criado (`kubectl create ns ai-iac-lab`)

## Anatomia de um bom prompt

```
Papel → Contexto → Instrução → Restrições → Formato de saída
```

Cada prompt na biblioteca segue essa estrutura com variáveis substituíveis.

## Organização da biblioteca de prompts

A biblioteca segue a convenção:
- **troubleshooting/** — diagnóstico de problemas (CrashLoop, OOM, networking)
- **geracao/** — criar artefatos (Helm charts, manifests, runbooks, Dockerfiles)
- **analise/** — interpretar dados (logs, métricas, correlação de eventos)

Para adicionar um novo prompt:
1. Identifique a categoria (troubleshooting, geracao, analise)
2. Crie um arquivo `.md` com: Descrição, Template, Variáveis, Exemplo de uso
3. Teste com o Kiro CLI antes de considerar pronto
