# Exercício — Crie seu próprio prompt

## Objetivo
Criar um novo prompt para a biblioteca seguindo a estrutura padrão.

## Escolha uma das situações

1. **ImagePullBackOff** — pod não consegue baixar a imagem
2. **Service retornando 503** — serviço existe mas retorna erro
3. **PVC stuck em Pending** — volume não provisiona

## Estrutura obrigatória

```markdown
# Prompt: [Nome descritivo]

## Descrição
[Quando usar este prompt — 1 frase]

## Template
[O prompt com {{VARIÁVEIS}} marcadas]

## Variáveis
| Variável | Descrição | Exemplo |
|---|---|---|
| ... | ... | ... |

## Exemplo de uso
[Comando copy-paste pronto com variáveis preenchidas]
```

## Critérios de qualidade

- [ ] Tem papel definido (SRE, DevOps, etc.)
- [ ] Inclui contexto do ambiente (k3s, namespace)
- [ ] Pede formato de saída específico
- [ ] Variáveis são claras e documentadas
- [ ] Exemplo de uso funciona copy-paste
- [ ] Inclui "o que já tentei" para evitar respostas óbvias

## Onde salvar

```bash
# Exemplo para ImagePullBackOff:
vi ~/ai-iac-labs/aula-2/prompts/troubleshooting/imagepullbackoff.md
```

## Validação

Depois de criar, teste o prompt preenchido com uma das ferramentas:
```bash
kiro chat "[seu prompt preenchido]"
# ou
gemini "[seu prompt preenchido]"
```

A resposta foi acionável? Se não, refine o template.
