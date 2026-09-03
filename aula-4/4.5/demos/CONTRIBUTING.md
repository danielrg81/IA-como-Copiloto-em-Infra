# Uso de IA neste repositorio

## Regras

1. IA e ferramenta. Quem faz merge e responsavel pelo codigo.
2. Todo codigo gerado por IA passa pelo mesmo CI que codigo escrito a mao.
3. PRs na zona vermelha precisam de review de seguranca.
4. Secrets NUNCA aparecem em codigo — nem como exemplo, nem como default.

## Zonas de uso

| Zona | Escopo | Regra |
|------|--------|-------|
| Verde | Docs, testes, scaffold, analise de logs | Uso livre |
| Amarela | Codigo para staging, refatoracao | Review de par + CI |
| Vermelha | Producao, RBAC, NetworkPolicy, secrets | Review de par + review seguranca + CI |

## O que funciona bem com IA

- Scaffold inicial de modulos Terraform
- Geracao de Helm charts a partir de specs
- Documentacao (README, runbooks)
- Troubleshooting e analise de logs
- Code review assistido

## O que precisa de cuidado extra

- RBAC e NetworkPolicy (IA tende a ser permissiva)
- Valores de recursos (IA nao conhece o tamanho do cluster)
- Referencias entre modulos (IA hardcoda strings)
- Tags de imagem (IA usa :latest por padrao)

## Processo

1. Gere com IA
2. Revise o output (especialmente seguranca e valores)
3. Rode localmente (`terraform plan` / `helm template`)
4. Abra PR com checklist preenchido
5. CI valida automaticamente
6. Reviewer humano aprova

## Metricas que acompanhamos

- Tempo medio de entrega de IaC
- Incidentes causados por codigo gerado com IA
- Taxa de adocao no time
- Rollbacks pos-deploy

## Excecoes

Incidentes Sev1 permitem pular review sincrono, mas:
- Dry-run e OBRIGATORIO mesmo em emergencia
- Toda excecao e registrada e revisada no post-mortem
