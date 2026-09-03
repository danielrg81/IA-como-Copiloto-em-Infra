# Anti-exemplo: Prompt sem estrutura para geração de IaC

## O que NÃO fazer

```
cria um deployment kubernetes
```

ou

```
cria um Helm chart
```

## Problemas

- Sem especificar imagem, versão, porta, réplicas
- Sem resource limits → pod pode consumir tudo
- Sem probes → Kubernetes não sabe se o app está saudável
- Tag `latest` → não reproduzível
- Sem security context → container roda como root
- Output genérico que precisa de muita edição

## Resultado típico

YAML funcional mas inseguro, sem limits, sem probes, com latest.
O profissional gasta mais tempo corrigindo do que teria gasto escrevendo do zero.
