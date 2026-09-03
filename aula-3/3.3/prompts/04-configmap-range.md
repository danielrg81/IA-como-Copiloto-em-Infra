# Prompt para gerar ConfigMap com range loop

Papel: Engenheiro Kubernetes sênior especializado em Helm.

Contexto: Helm chart "order-api" no k3s. Preciso de um ConfigMap com dados
configuráveis via values.yaml.

Gere o template `configmap.yaml` com:
- Condicional: só cria se .Values.configMap.enabled = true
- Usa {{- range $key, $val := .Values.configMap.data }} para iterar
- Labels usando helper "order-api.labels"
- Valores devem ser quoted (| quote)

Values exemplo:
```yaml
configMap:
  enabled: true
  data:
    APP_ENV: "production"
    LOG_LEVEL: "info"
    SERVICE_NAME: "order-api"
```

Formato: Template YAML completo.
Restrições: Funcionar com qualquer número de chaves no configMap.data.
