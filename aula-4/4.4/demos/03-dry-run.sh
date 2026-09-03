#!/bin/bash
# ============================================================
# Demo 3 — Dry-run: mostra o que VAI acontecer antes de fazer
# ============================================================
# Demonstra a diferenca entre --dry-run=client e --dry-run=server
# e mostra que dry-run e a camada mais barata de protecao.

DEMOS_DIR="$(cd "$(dirname "$0")" && pwd)"
NS="blast-radius-demo"

echo "======================================"
echo "  DEMO: Dry-run como guardrail"
echo "======================================"
echo ""

# ----------------------------------------------------------
echo "-- 1. dry-run=client (validacao LOCAL, sem cluster) --"
echo ""
echo "Comando: kubectl apply -f 01-setup-blast-radius.yaml --dry-run=client"
echo ""
kubectl apply -f "$DEMOS_DIR/01-setup-blast-radius.yaml" --dry-run=client 2>&1
echo ""
echo "-> Validou sintaxe localmente. Nao consultou o cluster."
echo ""

# ----------------------------------------------------------
echo "-- 2. dry-run=server (validacao NO CLUSTER, sem aplicar) --"
echo ""
echo "Comando: kubectl apply -f 01-setup-blast-radius.yaml --dry-run=server"
echo ""
kubectl apply -f "$DEMOS_DIR/01-setup-blast-radius.yaml" --dry-run=server 2>&1
echo ""
echo "-> Consultou a API real. Validou permissoes, quotas, APIs."
echo "-> Mas NAO aplicou nada. Zero blast radius."
echo ""

# ----------------------------------------------------------
echo "-- 3. Simulando acao perigosa com dry-run --"
echo ""
echo "Imagine que o agente quer deletar o namespace inteiro:"
echo "Comando: kubectl delete namespace $NS --dry-run=server"
echo ""
kubectl delete namespace $NS --dry-run=server 2>&1
echo ""
echo "-> dry-run mostra O QUE ACONTECERIA. Sem executar."
echo "-> Um humano ve isso e diz: 'NAO! Isso deleta tudo!'"
echo ""

echo "======================================"
echo "  Conclusao: dry-run = 5 segundos."
echo "  Incidente = 5 horas."
echo "======================================"
