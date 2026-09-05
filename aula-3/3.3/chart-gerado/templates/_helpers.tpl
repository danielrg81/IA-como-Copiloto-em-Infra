{{/*
Rótulos (labels) do Helm Chart order-api
*/}}
{{- define "order-api.labels" -}}
app.kubernetes.io/name: order-api
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Rótulos seletores (selectorLabels)
*/}}
{{- define "order-api.selectorLabels" -}}
app.kubernetes.io/name: order-api
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
