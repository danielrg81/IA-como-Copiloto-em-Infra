# Prompt Ruim — Sem estrutura

## Prompt

```
cria um deployment kubernetes
```

## Por que é ruim

- Sem papel: a IA não sabe se você é dev, SRE, estudante
- Sem contexto: qual app? qual imagem? qual namespace?
- Sem restrições: vai gerar algo genérico que não serve
- Sem formato: YAML? JSON? com comentários? sem?

## Execute e observe

```bash
kiro chat "cria um deployment kubernetes"
```

Anote: a resposta é genérica, provavelmente com `nginx:latest`, sem limits, sem probes.
