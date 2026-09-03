#!/bin/bash
# ============================================================
# Demo 5 — Rollback automatico: health check falha, volta atras
# ============================================================
# Simula deploy de versao com problema e rollback automatico
# quando o health check detecta falha.

NS="blast-radius-demo"
DEPLOY="app-a"
TIMEOUT=30

echo "======================================"
echo "  DEMO: Rollback automatico"
echo "======================================"
echo ""

# Guardar versao atual
echo "[DEPLOY] Versao atual:"
kubectl get deployment $DEPLOY -n $NS -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null
echo ""
echo ""

# Fazer upgrade para versao "quebrada" (imagem que nao existe)
echo "[DEPLOY] Atualizando para imagem inexistente (simulando deploy ruim)..."
kubectl set image deployment/$DEPLOY app=nginx:versao-inexistente -n $NS 2>&1
echo ""

# Monitoramento pos-acao (camada 4)
echo "[MONITORAMENTO] Aguardando pods ficarem Ready (timeout: ${TIMEOUT}s)..."
echo ""
kubectl rollout status deployment/$DEPLOY -n $NS --timeout=${TIMEOUT}s 2>&1
STATUS=$?

echo ""

# Decisao de rollback (camada 5)
if [ $STATUS -ne 0 ]; then
    echo "┌─────────────────────────────────────────────┐"
    echo "│ HEALTH CHECK FALHOU                         │"
    echo "│                                             │"
    echo "│ Pods nao ficaram Ready em ${TIMEOUT}s.        │"
    echo "│ Acionando ROLLBACK AUTOMATICO.              │"
    echo "└─────────────────────────────────────────────┘"
    echo ""
    echo "[ROLLBACK] Executando: kubectl rollout undo deployment/$DEPLOY -n $NS"
    kubectl rollout undo deployment/$DEPLOY -n $NS 2>&1
    echo ""
    echo "[ROLLBACK] Verificando recuperacao..."
    kubectl rollout status deployment/$DEPLOY -n $NS --timeout=30s 2>&1
    echo ""
    echo "[ROLLBACK] Servico restaurado. Incidente contido automaticamente."
else
    echo "[MONITORAMENTO] Deploy bem-sucedido. Todos os pods Ready."
fi
