# Checklist manual de review — para comparar com a IA

Use este checklist ANTES de pedir review à IA. Depois compare: o que você pegou vs. o que a IA pegou.

## Segurança

- [ ] RBAC segue princípio de menor privilégio? (verbs específicos, resources específicos)
- [ ] Secrets marcados como `sensitive = true`?
- [ ] Secrets via envFrom (não env inline com value)?
- [ ] NetworkPolicy restringe ingress a pods/namespaces específicos?
- [ ] NetworkPolicy especifica portas?
- [ ] Imagem com tag fixa (não :latest)?

## Resiliência

- [ ] Liveness probe configurado?
- [ ] Readiness probe configurado?
- [ ] Resource limits definidos?
- [ ] Resource requests definidos?
- [ ] Replicas >= 2?
- [ ] ServiceAccount dedicado?

## Boas práticas Terraform

- [ ] Variáveis com `type` e `description`?
- [ ] Valores reutilizáveis como variáveis (não hardcoded)?
- [ ] Resources referenciam uns aos outros (não strings)?
- [ ] Labels consistentes (app, managed-by)?
- [ ] Naming usa variáveis (parametrizável)?

## Operacional

- [ ] `terraform plan` executa sem erros?
- [ ] Dependências entre resources são explícitas?
- [ ] Outputs expõem informações úteis?
