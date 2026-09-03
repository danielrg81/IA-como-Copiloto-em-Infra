# Demo — Criar um novo prompt do zero

## Objetivo
Criar um prompt novo ao vivo seguindo a estrutura padrão da biblioteca.

## Situação
"Pod não consegue resolver DNS dentro do cluster."

## Prompt criado ao vivo

```bash
cat > ~/ai-iac-labs/aula-2/prompts/troubleshooting/dns-resolution.md << 'EOF'
# Prompt: DNS Resolution Failure

## Descrição
Diagnosticar pods que não conseguem resolver nomes DNS dentro do cluster.

## Template

```
Papel: SRE senior especializado em networking Kubernetes.

Ambiente: k3s single-node, namespace {{NAMESPACE}}
Sintoma: pod "{{POD_NAME}}" não resolve DNS — {{SYMPTOM_DETAIL}}

Testes realizados:
{{DNS_TESTS}}

CoreDNS status:
{{COREDNS_STATUS}}

O que já tentei:
- {{ATTEMPTED_FIXES}}

Pergunta: qual a causa raiz e como resolver?
Formato: diagnóstico + 3 passos de ação com comandos exatos.
```

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| NAMESPACE | Namespace | ai-iac-lab |
| POD_NAME | Pod afetado | order-api |
| SYMPTOM_DETAIL | Detalhe | nslookup postgres.ai-iac-lab.svc retorna NXDOMAIN |
| DNS_TESTS | Testes feitos | nslookup, dig, curl |
| COREDNS_STATUS | Status do CoreDNS | kubectl get pods -n kube-system -l k8s-app=kube-dns |
| ATTEMPTED_FIXES | Tentativas | restart do CoreDNS |

## Exemplo de uso

```bash
kiro chat "Papel: SRE senior especializado em networking Kubernetes.

Ambiente: k3s single-node, namespace ai-iac-lab
Sintoma: pod order-api não resolve DNS — nslookup postgres.ai-iac-lab.svc.cluster.local retorna NXDOMAIN

Testes realizados:
- kubectl exec order-api -- nslookup postgres → NXDOMAIN
- kubectl exec order-api -- cat /etc/resolv.conf → nameserver 10.43.0.10
- kubectl get svc -n kube-system kube-dns → ClusterIP 10.43.0.10

CoreDNS status:
- 1/1 Running, 0 restarts

O que já tentei:
- Restart do pod order-api
- Verificar que o Service postgres existe no namespace

Qual a causa raiz e como resolver?
Formato: diagnóstico + 3 passos de ação com comandos exatos."
```
EOF
```
