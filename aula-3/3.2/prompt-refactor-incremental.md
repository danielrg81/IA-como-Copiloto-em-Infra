# Prompt para aplicar refactoring incremental

Papel: Engenheiro de plataforma sênior com Terraform.

Contexto: Estou refatorando código Terraform (provider hashicorp/kubernetes)
que já está aplicado em um cluster k3s. Preciso aplicar as melhorias
incrementalmente, uma por vez, sem causar destroys.

O código atual já tem: namespace "legacy-app", deployment "my-app", service "my-app".

Aplique a seguinte melhoria:
- Extrair o secret "DB_PASSWORD" do env inline para um resource kubernetes_secret
- O deployment deve referenciar o secret via env_from
- Manter o mesmo nome de namespace e deployment (não renomear resources)

Restrições:
- O terraform plan NÃO pode mostrar "destroy" em nenhum resource existente
- Se precisar renomear um resource no código, use moved blocks
- Manter compatibilidade com o state atual

Formato: Código HCL pronto para substituir no arquivo, com comentário explicando o que mudou.
