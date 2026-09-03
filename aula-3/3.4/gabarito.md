# Gabarito — Problemas intencionais no código

| # | Severidade | Local | Problema | Impacto |
|---|-----------|-------|----------|---------|
| 1 | ALTA | Role, rule 1 | `resources = ["*"]` e `verbs = ["*"]` | Acesso total a todos os resources do namespace — viola least privilege |
| 2 | ALTA | Role, rule 2 | Secrets com verbs `create/update/delete` | Pod pode criar/modificar/deletar secrets — escalação de privilégios |
| 3 | ALTA | variable "db_password" | Sem `sensitive = true` | Password aparece em plain text no plan e no state |
| 4 | ALTA | NetworkPolicy | `ingress {}` sem `from` | Aceita tráfego de QUALQUER pod/namespace — policy inútil |
| 5 | ALTA | Deployment, env | Secret em env inline (`value = var.db_password`) | Password no manifest do pod — visível com kubectl describe |
| 6 | MÉDIA | Deployment, image | `nginx:latest` | Tag instável — deploy pode mudar de comportamento sem aviso |
| 7 | MÉDIA | Deployment | Sem liveness/readiness probes | Kubernetes não sabe se o pod está saudável — sem auto-recovery |
| 8 | MÉDIA | Deployment | Sem resource limits | Pod pode consumir todos os recursos do node — noisy neighbor |
| 9 | BAIXA | Secret, namespace | `namespace = "review-app"` hardcoded | Se renomear o namespace, o secret fica órfão — não acompanha a mudança |
| 10 | BAIXA | Deployment, replicas | `replicas = 3` hardcoded | Não parametrizável — precisa editar código para mudar |

## Prioridade de correção

1. **Primeiro:** RBAC (problems 1-2) — blast radius maior
2. **Segundo:** Secrets (problems 3, 5) — exposição de credenciais
3. **Terceiro:** NetworkPolicy (problem 4) — exposição de rede
4. **Quarto:** Resiliência (problems 6-8) — estabilidade
5. **Por último:** Boas práticas (problems 9-10) — manutenibilidade
