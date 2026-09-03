# Prompt para converter YAML existente em Terraform

Papel: Engenheiro de infraestrutura sênior com Terraform.

Contexto: Cluster k3s local com provider hashicorp/kubernetes.

Tenho este manifest Kubernetes em YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notification-api
  namespace: ai-iac-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: notification-api
  template:
    metadata:
      labels:
        app: notification-api
        version: "0.2.3"
    spec:
      containers:
      - name: notification-api
        image: hashicorp/http-echo:0.2.3
        args: ["-text=notification-api running"]
        ports:
        - containerPort: 5678
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
        livenessProbe:
          httpGet:
            path: /
            port: 5678
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: notification-api
  namespace: ai-iac-lab
spec:
  selector:
    app: notification-api
  ports:
  - port: 5678
    targetPort: 5678
  type: ClusterIP
```

Instrução: Converta para Terraform usando o provider hashicorp/kubernetes.
Mantenha a mesma funcionalidade. Use variáveis para valores que podem mudar entre ambientes.
Formato: Um único arquivo .tf com os resources.
