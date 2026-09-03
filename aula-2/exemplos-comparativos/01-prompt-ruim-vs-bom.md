# Comparativo: Prompt Ruim vs. Prompt Bom

## Cenário
Precisamos criar um Deployment Kubernetes para um serviço de API.

---

##  Prompt Ruim

```
cria um deployment kubernetes
```

### Problemas:
- Sem contexto do ambiente
- Sem especificar imagem, porta, recursos
- Sem restrições de segurança
- Sem formato de saída esperado

### Output típico:
Código genérico, sem resource limits, sem labels úteis, porta aleatória.

---

##  Prompt Bom

```
Papel: Você é um engenheiro de infraestrutura sênior especializado em Kubernetes.

Contexto: Estamos rodando um cluster k3s single-node para desenvolvimento.
O namespace é "ai-iac-lab" e seguimos a naming convention "{app}-{recurso}".

Instrução: Crie um Deployment para um serviço de API REST.

Specs:
- Nome: order-api
- Imagem: hashicorp/http-echo:0.2.3
- Porta: 5678
- Replicas: 2
- Args: ["-text=order-api running"]

Restrições:
- Incluir resource limits (CPU: 100m, memory: 128Mi)
- Incluir liveness probe em /
- Labels: app, version, managed-by

Formato de saída: YAML válido pronto para kubectl apply
```

### Por que funciona:
- **Papel** → direciona nível técnico
- **Contexto** → modelo sabe o ambiente
- **Instrução** → objetivo claro
- **Restrições** → elimina configurações inseguras
- **Formato** → output pronto para usar
