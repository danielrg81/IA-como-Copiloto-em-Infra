# Prompt para gerar o _helpers.tpl

Papel: Engenheiro Kubernetes sênior especializado em Helm.

Contexto: Estou criando um Helm chart para o serviço "order-api" no k3s, namespace ai-iac-lab.

Gere um arquivo `_helpers.tpl` com:
- Helper "order-api.labels" com labels padrão: app.kubernetes.io/name, app.kubernetes.io/version, app.kubernetes.io/managed-by, team
- Helper "order-api.selectorLabels" com apenas o subset usado em matchLabels

Os valores devem vir de .Values.app.name, .Values.image.tag, .Release.Service e .Values.app.team.

Formato: Arquivo _helpers.tpl completo, com comentários explicando cada helper.
Restrições: Seguir convenções do Helm (usar {{- define }}, {{- end }}).
