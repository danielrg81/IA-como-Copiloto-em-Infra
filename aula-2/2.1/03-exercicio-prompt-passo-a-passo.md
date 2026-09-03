# Exercício: Construa seu prompt passo a passo

## Objetivo

Transformar um prompt ruim em um prompt estruturado, adicionando um elemento por vez e observando a diferença.

---

## Passo 1 — Só instrução (baseline)

```bash
kiro chat "cria um service kubernetes"
```

Observe: resultado genérico.

---

## Passo 2 — Adicionar contexto

```bash
kiro chat "Contexto: tenho um deployment chamado order-api no namespace ai-iac-lab, porta 8080.

Cria um Service Kubernetes para expor esse deployment."
```

Observe: já fica específico pro app, mas pode ter escolhas que você não quer.

---

## Passo 3 — Adicionar restrições

```bash
kiro chat "Contexto: tenho um deployment chamado order-api no namespace ai-iac-lab, porta 8080.

Cria um Service Kubernetes para expor esse deployment.

Restrições:
- Tipo ClusterIP
- Selector: app=order-api
- Port 80 → targetPort 8080
- Incluir namespace no manifest"
```

Observe: agora a IA não decide por você.

---

## Passo 4 — Adicionar papel + formato

```bash
kiro chat "Papel: engenheiro de plataforma que preza por manifests limpos e sem redundância.

Contexto: tenho um deployment chamado order-api no namespace ai-iac-lab, porta 8080.

Instrução: Crie um Service Kubernetes para expor esse deployment.

Restrições:
- Tipo ClusterIP
- Selector: app=order-api
- Port 80 → targetPort 8080
- Incluir namespace no manifest

Formato: YAML puro, sem comentários, sem explicações."
```

Observe: output limpo, pronto para `kubectl apply -f`.

---

## Reflexão

| Passo | O que adicionou | Impacto na resposta |
|---|---|---|
| 1 | Nada | Genérico, inutilizável |
| 2 | Contexto | Específico mas com escolhas arbitrárias |
| 3 | Restrições | Elimina ambiguidade |
| 4 | Papel + Formato | Output profissional e pronto para usar |
