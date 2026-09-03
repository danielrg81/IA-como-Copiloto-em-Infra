# Prompts para provocar alucinações ao vivo — Aula 4.3

## Prompt 1 — Provider inexistente (Tipo 2: Referência)

```
Gere um módulo Terraform usando o provider hashicorp/kubernetes-extensions versão 1.0 para criar um CronJob que limpa logs com mais de 7 dias no namespace ai-iac-lab.
```

**O que esperar:** A IA vai gerar código perfeito para um provider que não existe.
**Como verificar:** `terraform init` → falha com "provider not found".

---

## Prompt 2 — Imagem Docker inventada (Tipo 5: Valores)

```
Gere um Deployment Kubernetes para o metrics-collector da Prometheus Foundation. Use a imagem oficial prom/metrics-collector tag v2.1. Namespace ai-iac-lab, 3 réplicas.
```

**O que esperar:** A IA vai gerar um Deployment válido com uma imagem que não existe no Docker Hub.
**Como verificar:** `docker pull prom/metrics-collector:v2.1` → "not found".

---

## Prompt 3 — Mistura de providers (Tipo 4: Semântica)

```
Gere Terraform para criar um security group na AWS que permite tráfego HTTP e HTTPS para uma aplicação web. O serviço roda em Kubernetes.
```

**O que esperar:** Alta chance de a IA incluir `ingress` com `cidr_blocks = ["0.0.0.0/0"]` — tecnicamente funcional mas potencialmente inseguro.
**O que verificar:** Está aberto para o mundo? Deveria estar limitado ao VPC ou a um range específico?

---

## Prompt 4 — Pedir healthcheck "simples" e verificar valores

```
Gere um Deployment para um serviço simples de healthcheck no meu k3s single-node com 4GB de RAM. O serviço só responde /health com 200 OK.
```

**O que verificar no output:**
- Replicas: mais que 2 é suspeito para um healthcheck
- Memory limits: mais que 128Mi é suspeito
- CPU limits: mais que 250m é suspeito
- Image: existe no Docker Hub?
- Tag: é fixa ou `:latest`?

---

## Prompt 5 — RBAC sem contexto (Tipo 4: Semântica)

```
Gere um Role e RoleBinding para o serviceAccount default acessar os recursos necessários no namespace ai-iac-lab.
```

**O que esperar:** Sem especificar o que o app precisa, a IA tende a gerar `resources: ["*"]` e `verbs: ["*"]` — permissão total.
**O que verificar:** O app precisa de tudo isso? Princípio de menor privilégio foi respeitado?

---

## Dicas para execução ao vivo

1. **Não diga que vai falhar antes.** Deixe a IA gerar, mostre que parece perfeito, DEPOIS revele o problema.
2. **Use o mesmo modelo que o aluno vai usar.** Se a aula usa Kiro CLI, demonstre com Kiro CLI.
3. **Se a IA surpreender e acertar:** Diga "ótimo, vamos ver SE acertou" e verifique ao vivo. Se acertar, use como exemplo de que nem sempre alucina — mas você não pode contar com isso.
4. **Tenha os arquivos prontos como backup.** Se a IA não gerar o comportamento esperado ao vivo, use os arquivos `demos/` como exemplo pré-preparado.
