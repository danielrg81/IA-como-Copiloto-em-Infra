# Prompt 3 — Gerar documentação do módulo

Papel: Technical writer de infraestrutura.

Contexto: Módulo Terraform que provisiona infraestrutura completa para o serviço payment-api em um cluster k3s (provider hashicorp/kubernetes).

Gere um README.md para o módulo com:

1. **Descrição** — o que o módulo cria (1-2 parágrafos)
2. **Recursos criados** — tabela com tipo e nome de cada resource
3. **Pré-requisitos** — o que precisa estar instalado/configurado
4. **Uso rápido** — exemplo com terraform init/plan/apply
5. **Inputs** — tabela com todas as variáveis (nome, tipo, default, descrição)
6. **Outputs** — tabela com todos os outputs (nome, descrição)
7. **Validação** — comandos kubectl para confirmar que funcionou
8. **Cleanup** — como destruir tudo

Formato: Markdown com tabelas e blocos de código.
Restrições: Não incluir valores de secrets. Ser conciso mas completo.

---

Variables do módulo (variables.tf):

[COLE O CONTEÚDO DE variables.tf AQUI]

---

Outputs do módulo (outputs.tf):

[COLE O CONTEÚDO DE outputs.tf AQUI]
