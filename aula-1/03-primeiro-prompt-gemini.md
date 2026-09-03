# Primeiro contato com Gemini CLI

## Configuração

```bash
# Configurar API key (obter em https://aistudio.google.com/apikey)
export GEMINI_API_KEY="sua-chave-aqui"

# Adicionar ao .bashrc para persistir
echo 'export GEMINI_API_KEY="sua-chave-aqui"' >> ~/.bashrc
```

## Exercício 1 — Primeiro prompt

```bash
gemini "O que é k3s e quais as diferenças para um Kubernetes completo?"
```

## Exercício 2 — Gerar código

```bash
gemini "Gere um YAML de Deployment Kubernetes para um nginx com 2 réplicas na porta 80."
```

## Exercício 3 — Explicar um conceito

```bash
gemini "Explique o conceito de Helm chart em 3 frases, como se eu fosse um sysadmin migrando para Kubernetes."
```

## Exercício 4 — Troubleshooting

```bash
gemini "Um pod está com status ImagePullBackOff. Quais são as 3 causas mais comuns e como verificar cada uma?"
```

## Exercício 5 — Comparar com Kiro

Execute o mesmo prompt no Kiro e no Gemini:

```bash
# Gemini (só texto, não executa comandos)
gemini "Liste os pods rodando no namespace kube-system de um k3s."

# Kiro (pode executar o comando real)
kiro chat "Liste os pods rodando no namespace kube-system."
```

## O que observar

- Gemini responde com texto/código mas **não executa comandos** no seu ambiente
- Kiro pode ler arquivos e executar comandos — é um agente, não só um chat
- Gemini é útil para perguntas conceituais e geração de código isolado
- Para tarefas que precisam de contexto local, Kiro é mais adequado
