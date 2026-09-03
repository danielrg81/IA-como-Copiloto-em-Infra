#!/bin/bash
# ============================================================
# Demo 4 — Aprovacao humana: o agente propoe, humano decide
# ============================================================
# Simula o padrao de guardrail onde o agente nunca executa
# sem confirmacao explícita do operador.

NS="blast-radius-demo"

echo "======================================"
echo "  DEMO: Aprovacao humana como guardrail"
echo "======================================"
echo ""
echo "Cenario: o agente detectou que app-a esta com alta latencia"
echo "e propoe escalar de 2 para 5 replicas."
echo ""

# Agente analisa
echo "[AGENTE] Investigando..."
REPLICAS=$(kubectl get deployment app-a -n $NS -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "2")
echo "[AGENTE] Replicas atuais de app-a: $REPLICAS"
echo "[AGENTE] CPU usage elevado. Proposta: escalar para 5 replicas."
echo ""

# Agente calcula blast radius
echo "┌─────────────────────────────────────────────┐"
echo "│ PROPOSTA DO AGENTE                          │"
echo "│                                             │"
echo "│ Acao: kubectl scale deployment/app-a        │"
echo "│       --replicas=5 -n $NS     │"
echo "│                                             │"
echo "│ Blast radius: deployment app-a apenas       │"
echo "│ Reversivel: sim (scale down)                │"
echo "│ Risco: baixo (nao deleta dados)             │"
echo "└─────────────────────────────────────────────┘"
echo ""

# Gate de aprovacao
read -p "[GUARDRAIL] Aprovar esta acao? (s/n): " resposta

if [ "$resposta" = "s" ]; then
    echo ""
    echo "[AGENTE] Executando: kubectl scale deployment/app-a --replicas=5 -n $NS"
    kubectl scale deployment/app-a --replicas=5 -n $NS 2>&1
    echo ""
    echo "[AGENTE] Verificando resultado..."
    sleep 2
    kubectl get pods -n $NS -l app=app-a 2>&1
    echo ""
    echo "[AGENTE] Acao concluida com sucesso."
else
    echo ""
    echo "[AGENTE] Acao BLOQUEADA pelo operador. Nenhuma mudanca aplicada."
fi
