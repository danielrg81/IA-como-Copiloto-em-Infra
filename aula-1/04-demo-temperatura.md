# Demonstração: Efeito de Temperatura e Variação

## Conceito

**Temperatura** controla a aleatoriedade das respostas:
- Temperatura baixa (0.0-0.3) → respostas determinísticas, repetíveis
- Temperatura alta (0.7-1.0) → respostas criativas, variadas

Para IaC, queremos temperatura **baixa** — código precisa ser previsível.

## Experimento: Mesmo prompt, respostas diferentes

### Prompt fixo:
```
Gere um Service Kubernetes do tipo ClusterIP para um app chamado "api" na porta 8080.
```

### Teste 1 — Envie 3 vezes seguidas:
```bash
# Primeira vez
kiro chat "Gere um Service Kubernetes ClusterIP para app=api porta 8080. Só o YAML, sem explicação."

# Segunda vez (mesmo prompt)
kiro chat "Gere um Service Kubernetes ClusterIP para app=api porta 8080. Só o YAML, sem explicação."

# Terceira vez
kiro chat "Gere um Service Kubernetes ClusterIP para app=api porta 8080. Só o YAML, sem explicação."
```

### O que observar:
- Os YAMLs são idênticos ou têm variações?
- Nomes, labels, annotations mudam?
- A estrutura base é a mesma?

## Experimento: Mais contexto = menos variação

### Prompt vago:
```bash
kiro chat "Cria um deployment pro meu app"
```
(Execute 2x e compare — provavelmente outputs bem diferentes)

### Prompt específico:
```bash
kiro chat "Crie um Deployment com:
- name: api
- image: nginx:1.25
- replicas: 1
- port: 80
- label: app=api
Formato: YAML puro, sem comentários."
```
(Execute 2x e compare — outputs quase idênticos)

## Lição

> Quanto mais específico o prompt, menos a "temperatura" importa.
> Para IaC, especificidade é sua melhor ferramenta contra variação indesejada.

## Por que isso importa para infra

- Código de infra precisa ser **reproduzível** — mesma entrada, mesma saída
- Se o prompt é vago, cada execução gera algo diferente → impossível versionar
- Prompts específicos funcionam como "templates determinísticos" para a IA
