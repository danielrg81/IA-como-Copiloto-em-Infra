#!/bin/bash
# ============================================================
# Script principal — Aula 4.4: Blast Radius e Guardrails
# ============================================================
# Prepara o ambiente e guia as demonstracoes.
#
# Uso:
#   1. ./run-demos.sh setup    — cria namespace e workloads
#   2. ./run-demos.sh cleanup  — remove tudo ao final
#
# As demos individuais (03, 04, 05) sao executadas manualmente
# durante a aula para controlar o ritmo.
# ============================================================

DEMOS_DIR="$(cd "$(dirname "$0")" && pwd)"
NS="blast-radius-demo"

case "${1:-help}" in
    setup)
        echo "======================================"
        echo "  SETUP: Criando ambiente de demo"
        echo "======================================"
        echo ""
        kubectl apply -f "$DEMOS_DIR/01-setup-blast-radius.yaml"
        echo ""
        echo "Aguardando pods ficarem prontos..."
        kubectl wait --for=condition=ready pod -l app=app-a -n $NS --timeout=60s 2>&1
        kubectl wait --for=condition=ready pod -l app=app-b -n $NS --timeout=60s 2>&1
        echo ""
        echo "Ambiente pronto:"
        kubectl get all -n $NS
        echo ""
        ;;
    cleanup)
        echo "======================================"
        echo "  CLEANUP: Removendo ambiente de demo"
        echo "======================================"
        echo ""
        kubectl delete namespace $NS --ignore-not-found
        echo "Pronto."
        ;;
    *)
        echo "Uso: $0 {setup|cleanup}"
        echo ""
        echo "Ordem das demos:"
        echo "  1. $0 setup                    — prepara ambiente"
        echo "  2. ./03-dry-run.sh             — demonstra dry-run"
        echo "  3. ./04-aprovacao-humana.sh    — demonstra gate humano"
        echo "  4. ./05-rollback-automatico.sh — demonstra rollback"
        echo "  5. $0 cleanup                  — limpa tudo"
        ;;
esac
