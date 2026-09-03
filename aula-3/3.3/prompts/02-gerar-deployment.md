# Prompt para gerar deployment com conditionals

Papel: Engenheiro Kubernetes sênior especializado em Helm.

Contexto: Helm chart "order-api" com _helpers.tpl já definido (helpers: order-api.labels e order-api.selectorLabels).

Gere o template `deployment.yaml` com:
- Usa {{- include "order-api.labels" }} para labels
- Usa {{- include "order-api.selectorLabels" }} para matchLabels
- Replicas condicional: se autoscaling.enabled=true, NÃO define replicas (HPA controla)
- Container com image, port, resources (usando toYaml), args (condicional)
- Liveness e readiness probes configuráveis via values
- envFrom de ConfigMap (condicional: se configMap.enabled=true)

Values disponíveis:
- .Values.app.name, .Values.replicaCount
- .Values.image.repository, .Values.image.tag
- .Values.containerPort, .Values.args
- .Values.resources (objeto com limits/requests)
- .Values.probes.liveness.{path, initialDelaySeconds, periodSeconds}
- .Values.probes.readiness.{path, initialDelaySeconds, periodSeconds}
- .Values.autoscaling.enabled, .Values.configMap.enabled

Formato: Template YAML completo para Helm.
Restrições: Usar nindent corretamente. Não hardcodar valores.
