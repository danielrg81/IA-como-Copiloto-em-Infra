#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"
mkdir -p ~/.kube
vagrant ssh -c "sudo cat /etc/rancher/k3s/k3s.yaml" 2>/dev/null > ~/.kube/config
chmod 600 ~/.kube/config

echo "kubeconfig copiado para ~/.kube/config"
kubectl cluster-info
