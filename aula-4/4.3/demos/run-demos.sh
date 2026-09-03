#!/bin/bash
# ============================================================
# Script de demonstração — Aula 4.3: Alucinações em IaC
# ============================================================
# Mostra como cada camada de validação pega (ou não)
# diferentes tipos de alucinação gerada por IA.
#
# Pré-requisitos:
#   - k3s rodando com kubectl configurado
#   - namespace ai-iac-lab criado
#   - Terraform instalado (para demo 1)
#
# Uso: ./run-demos.sh
# ============================================================
set -euo pipefail

DEMOS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

header() {
  echo ""
  echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
  echo ""
}

demo_title() {
  echo -e "${YELLOW}┌─────────────────────────────────────────────────┐${NC}"
  echo -e "${YELLOW}│${NC} ${BOLD}DEMO $1${NC}"
  echo -e "${YELLOW}└─────────────────────────────────────────────────┘${NC}"
  echo ""
}

show_file() {
  echo -e "${BLUE}📄 Arquivo: $1${NC}"
  echo -e "${BLUE}───────────────────────────────────────────────────${NC}"
  cat "$1"
  echo -e "${BLUE}───────────────────────────────────────────────────${NC}"
  echo ""
}

run_cmd() {
  echo -e "${BOLD}▶ Comando:${NC} $1"
  echo ""
  eval "$1" 2>&1 || true
  echo ""
}

conclusion() {
  echo -e "${GREEN}✓ Conclusão:${NC} $1"
  echo ""
}

warning() {
  echo -e "${RED}⚠ Atenção:${NC} $1"
  echo ""
}

gate() {
  echo ""
  echo -e "${YELLOW}Pressione ENTER para continuar para a próxima demo...${NC}"
  read -r
}

# ============================================================
header "DEMONSTRAÇÃO: Alucinações em IaC"
echo -e "Este script mostra 5 tipos de alucinação que uma IA pode gerar"
echo -e "e como cada ferramenta de validação reage a elas."
echo ""
echo -e "  ${GREEN}❌ = ferramenta DETECTA o erro${NC}"
echo -e "  ${RED}✅ = ferramenta ACEITA (falso negativo perigoso)${NC}"
echo ""
gate

# ----------------------------------------------------------
demo_title "1: Provider que não existe"
echo -e "A IA gerou código Terraform para um provider fictício."
echo -e "O código ${BOLD}parece perfeito${NC} sintaticamente."
echo ""

show_file "$DEMOS_DIR/01-provider-inexistente.tf"

echo -e "${BOLD}Testando:${NC} terraform init detecta?"
echo ""
run_cmd "cd /tmp && rm -rf demo-provider && mkdir demo-provider && cp $DEMOS_DIR/01-provider-inexistente.tf demo-provider/main.tf && cd demo-provider && terraform init 2>&1 | tail -5"

conclusion "terraform init ${GREEN}DETECTA${NC} — provider não existe no registry."
warning "Mas se o aluno não rodar init, o código parece válido!"

gate

# ----------------------------------------------------------
demo_title "2: API deprecated (extensions/v1beta1)"
echo -e "A IA gerou um Deployment usando uma API que foi removida no k8s 1.16+."
echo -e "Parece YAML válido, mas o cluster não aceita."
echo ""

show_file "$DEMOS_DIR/02-api-deprecated.yaml"

echo -e "${BOLD}Testando:${NC} kubectl apply --dry-run=server detecta?"
echo ""
run_cmd "kubectl apply --dry-run=server -f $DEMOS_DIR/02-api-deprecated.yaml"

conclusion "O cluster ${GREEN}REJEITA${NC} — API extensions/v1beta1 não existe mais."
warning "helm template e kubectl apply --dry-run=client NÃO pegariam isso!"

gate

# ----------------------------------------------------------
demo_title "3: Valores absurdos (50 réplicas, 4Gi por pod)"
echo -e "A IA gerou um deployment com 50 réplicas e 4Gi de RAM por pod."
echo -e "Num k3s single-node com ~4GB, isso é impossível de agendar."
echo ""

show_file "$DEMOS_DIR/03-valores-absurdos.yaml"

echo -e "${BOLD}Recursos disponíveis no node:${NC}"
kubectl describe node 2>/dev/null | grep -A 5 "Allocatable" || echo "(não disponível)"
echo ""

echo -e "${BOLD}Testando:${NC} kubectl apply --dry-run=server detecta?"
echo ""
run_cmd "kubectl apply --dry-run=server -f $DEMOS_DIR/03-valores-absurdos.yaml"

warning "dry-run=server ${RED}ACEITA${NC}! O cluster não valida capacidade no dry-run."
conclusion "Se aplicar de verdade, os pods ficam em ${RED}Pending${NC} eternamente."
echo -e "→ ${BOLD}Só review humano + conhecimento do ambiente detecta isso.${NC}"

gate

# ----------------------------------------------------------
demo_title "4: NetworkPolicy que não protege nada"
echo -e "A IA gerou uma NetworkPolicy com ingress vazio = permite TUDO."
echo -e "É ${RED}pior${NC} que não ter policy: dá ${RED}falsa sensação de segurança${NC}."
echo ""

show_file "$DEMOS_DIR/04-networkpolicy-permissiva.yaml"

echo -e "${BOLD}Testando:${NC} kubectl apply --dry-run=server detecta?"
echo ""
run_cmd "kubectl apply --dry-run=server -f $DEMOS_DIR/04-networkpolicy-permissiva.yaml"

warning "dry-run=server ${RED}ACEITA${NC}! YAML válido, mas semanticamente inútil."
conclusion "Nenhuma ferramenta automática detecta. Precisa de review humano ou OPA/Kyverno."

gate

# ----------------------------------------------------------
demo_title "5: RBAC com verbs: ['*'] (acesso total)"
echo -e "A IA gerou uma Role com ${RED}resources: ['*'] e verbs: ['*']${NC}."
echo -e "Qualquer pod com esse ServiceAccount pode fazer TUDO no namespace."
echo ""

show_file "$DEMOS_DIR/05-rbac-permissivo.yaml"

echo -e "${BOLD}Testando:${NC} kubectl apply --dry-run=server detecta?"
echo ""
run_cmd "kubectl apply --dry-run=server -f $DEMOS_DIR/05-rbac-permissivo.yaml"

warning "dry-run=server ${RED}ACEITA${NC}! RBAC permissivo é YAML válido."
conclusion "Nenhum lint detecta. Só review humano ou policy engine (OPA/Kyverno)."

# ----------------------------------------------------------
header "RESUMO"

echo -e "┌──────────────────────┬────────────┬──────────────┬───────────────┐"
echo -e "│ ${BOLD}Tipo de alucinação${NC}   │ ${BOLD}tf validate${NC}│ ${BOLD}dry-run=server${NC}│ ${BOLD}Review humano${NC} │"
echo -e "├──────────────────────┼────────────┼──────────────┼───────────────┤"
echo -e "│ Provider inexistente │ ${GREEN}detecta${NC}    │      —       │ ${GREEN}detecta${NC}       │"
echo -e "│ API deprecated       │     —      │ ${GREEN}detecta${NC}      │ ${GREEN}detecta${NC}       │"
echo -e "│ Valores absurdos     │     —      │ ${RED}NÃO detecta${NC}  │ ${GREEN}detecta${NC}       │"
echo -e "│ Policy permissiva    │     —      │ ${RED}NÃO detecta${NC}  │ ${GREEN}detecta${NC}       │"
echo -e "│ RBAC permissivo      │     —      │ ${RED}NÃO detecta${NC}  │ ${GREEN}detecta${NC}       │"
echo -e "└──────────────────────┴────────────┴──────────────┴───────────────┘"
echo ""
echo -e "${BOLD}Conclusão:${NC}"
echo -e "  • Ferramentas automáticas pegam erros ${GREEN}sintáticos${NC} e de ${GREEN}API${NC}"
echo -e "  • Erros ${RED}semânticos${NC} (lógica, segurança, capacidade) passam em TUDO"
echo -e "  • ${BOLD}Review humano é INSUBSTITUÍVEL para segurança em IaC${NC}"
echo ""
