# Prompt para adicionar HPA ao chart

Papel: Engenheiro Kubernetes sênior especializado em Helm.

Contexto: Helm chart "order-api" instalado no k3s, namespace ai-iac-lab.
O deployment já existe e funciona com réplicas fixas.

Adicione um HPA (HorizontalPodAutoscaler) ao chart:
- Condicional: só cria se .Values.autoscaling.enabled = true
- Target: Deployment com o nome de .Values.app.name
- minReplicas, maxReplicas, targetCPU vêm do values
- API version: autoscaling/v2
- Labels usando o helper "order-api.labels"

Gere também os valores correspondentes para adicionar ao values.yaml.

Formato: template hpa.yaml + trecho do values.yaml
Restrições: Quando HPA está ativo, o deployment NÃO deve definir spec.replicas (conflito).
