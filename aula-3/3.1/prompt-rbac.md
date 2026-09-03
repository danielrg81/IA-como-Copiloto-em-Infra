# Prompt para iteração — adicionar RBAC (Passo 5)

Papel: Engenheiro de infraestrutura sênior com Terraform.

Contexto: Já tenho um namespace "app-production" com um deployment "order-api"
gerenciado por Terraform no provider hashicorp/kubernetes.
O cluster é k3s local.

Instrução: Adicione RBAC para o deployment order-api:
- ServiceAccount dedicado para o pod
- Role com permissões mínimas: ler configmaps, secrets e listar pods no namespace
- RoleBinding vinculando o ServiceAccount ao Role

Restrições: Princípio de menor privilégio. Referenciar o namespace via resource Terraform (não hardcoded).
Formato: rbac.tf separado, usando as mesmas variáveis de variables.tf.
