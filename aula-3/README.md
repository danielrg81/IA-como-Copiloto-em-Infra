# Aula 3 — Labs de Terraform com k3s

## Pré-requisito

Executar o lab 01 primeiro para criar o namespace usado pelos demais:

```bash
cd ~/ai-iac-labs/aula-3/01-namespace
terraform init && terraform apply -auto-approve
```

## Labs

| Lab | O que faz | Conceitos |
|-----|-----------|-----------|
| 01-namespace | Cria namespace com labels | Provider kubernetes, metadata |
| 02-nginx-deploy | Deployment + Service | Replicas, selector, resources, ClusterIP |
| 03-config-secret | ConfigMap + Secret + Pod | env_from, referências entre recursos |

## Como usar

```bash
cd ~/ai-iac-labs/aula-3/<lab>
terraform init
terraform plan      # sempre revisar antes de aplicar
terraform apply -auto-approve

# Verificar
kubectl get all -n ai-iac-lab

# Limpar
terraform destroy -auto-approve
```

## Exercícios com IA

1. Peça para a IA gerar o mesmo recurso via prompt e compare com o código aqui
2. Peça para refatorar: "extraia variáveis para imagem e replicas"
3. Peça code review: "analise segurança e boas práticas deste Terraform"
