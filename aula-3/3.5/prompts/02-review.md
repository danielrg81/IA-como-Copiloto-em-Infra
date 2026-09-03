# Prompt 2 — Code review de segurança e boas práticas

Papel: Security engineer sênior fazendo code review de Terraform.

Contexto: Código Terraform que gerencia recursos Kubernetes no k3s via provider hashicorp/kubernetes. O código ainda NÃO foi aplicado (pré-review).

Faça code review focando em:

1. **Segurança**
   - Secrets estão marcados como sensitive?
   - RBAC segue princípio de menor privilégio?
   - NetworkPolicy é restritiva o suficiente?
   - Imagem usa tag fixa (não :latest)?

2. **Boas práticas Terraform**
   - Variáveis têm description e type?
   - Resources referenciam uns aos outros (não strings hardcoded)?
   - Outputs expõem informações úteis sem vazar secrets?
   - Naming é consistente?

3. **Resiliência Kubernetes**
   - Probes configurados corretamente?
   - Resource limits e requests definidos?
   - Replicas > 1?
   - Pod usa ServiceAccount dedicado (não default)?

4. **Potenciais problemas**
   - Algo que pode falhar no apply?
   - Dependências implícitas que deveriam ser explícitas?
   - Conflitos de porta ou nome?

Formato de resposta: Lista de findings com severidade (ALTA/MÉDIA/BAIXA), o que está errado, e sugestão de fix com código.

---

Código para review (main.tf):

[COLE O CONTEÚDO DE main.tf AQUI]
