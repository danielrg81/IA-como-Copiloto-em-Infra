# Politica de Uso de IA — [Nome da Empresa]

## Principios

1. IA e ferramenta. Quem faz merge e responsavel pelo codigo.
2. Todo codigo gerado por IA passa pelo mesmo CI que codigo escrito a mao.
3. Controles sao proporcionais ao risco do use case.
4. Sem registro, sem uso. Toda utilizacao e rastreavel.

## Classificacao de risco

| Nivel | Use cases | Controle minimo |
|-------|-----------|-----------------|
| Baixo | Documentacao, estudo, scaffold, analise de logs dev | Uso livre |
| Medio | Codigo para staging, troubleshooting, refatoracao | Review de par + CI |
| Alto | Codigo para producao, seguranca, RBAC, networking | Review par + security + CI |
| Critico | Agentes autonomos, auto-remediacao em prod | Todas as camadas + aprovacao comite |

## Responsabilidades

| Papel | Responsabilidade |
|-------|-----------------|
| Desenvolvedor/SRE | Validar output antes de merge |
| Reviewer | Verificar checklist de seguranca |
| Tech Lead | Classificar use cases por nivel de risco |
| CISO/Security | Aprovar use cases de nivel critico |
| Comite de IA | Revisar metricas, ajustar politica trimestralmente |

## Ferramentas aprovadas

- [Listar ferramentas aprovadas pela empresa: ex. Kiro CLI, Gemini CLI, GitHub Copilot]
- Ferramentas nao listadas precisam de aprovacao do Tech Lead antes do uso

## O que funciona bem com IA

- Scaffold inicial de modulos Terraform e Helm charts
- Documentacao (README, runbooks, ADRs)
- Troubleshooting e analise de logs
- Geracao de testes
- Code review assistido

## O que precisa de cuidado extra

- RBAC e NetworkPolicy (IA tende a ser permissiva)
- Valores de recursos (IA nao conhece o ambiente real)
- Tags de imagem (IA usa :latest por padrao)
- Secrets (IA pode hardcodar valores)

## Processo padrao

1. Gere com IA
2. Revise o output (seguranca, valores, permissoes)
3. Rode localmente (terraform plan / helm template)
4. Abra PR com checklist preenchido
5. CI valida automaticamente (bloqueante)
6. Reviewer humano aprova
7. Merge

## Excecoes

| Situacao | Pode pular | NUNCA pular |
|----------|-----------|-------------|
| Incidente Sev1 | Review sincrono | Dry-run antes de apply |
| Hotfix urgente | CI completo | Validacao basica |
| Ambiente de teste | Aprovacao | Nada — sandbox e livre |

Toda excecao e registrada e revisada no post-mortem.

## Metricas

- Tempo medio de entrega de IaC
- Incidentes causados por codigo gerado com IA
- Taxa de adocao (% do time usando)
- Rollbacks pos-deploy

Revisao trimestral pelo comite de IA.

## Frameworks de referencia

- AWS Well-Architected Responsible AI Lens
- Microsoft Responsible AI Standard + Cloud Adoption Framework
- Google Cloud SAIF + Recommended AI Controls

## Vigencia

Esta politica entra em vigor em [data] e sera revisada trimestralmente.
Ultima atualizacao: [data]
