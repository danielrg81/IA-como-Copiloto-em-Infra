# Anti-exemplo: Prompt sem estrutura para análise de logs

## O que NÃO fazer

```
analisa esses logs pra mim:

[cola 500 linhas de log com INFO, DEBUG, WARN, ERROR misturados]
```

## Problemas

- Estoura ou dilui a janela de contexto
- Modelo perde foco com ruído (linhas INFO/DEBUG)
- Sem contexto do ambiente, sintoma ou impacto
- Análise superficial: "verifique se o banco está rodando"

## Resultado típico

Resposta genérica listando 10 possíveis causas sem evidência concreta.
