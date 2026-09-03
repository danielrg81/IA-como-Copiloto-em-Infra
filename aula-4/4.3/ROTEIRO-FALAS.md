# Roteiro de Falas — Aula 4.3: Alucinações em IaC

## Tempo estimado: 12-15 minutos

---

## Abertura (2 min)

> Na 4.1 entendemos a diferença entre chatbot e agente. Na 4.2 vimos o que o mercado oferece em termos de frameworks. Tudo muito promissor. Mas agora eu preciso contar pra vocês uma história que vai mudar a forma como vocês olham pro código que a IA gera.

> Imagina o seguinte cenário. Sexta-feira, 17h30. Sprint acabando. O tech lead cobrou o módulo Terraform do novo serviço payment-api duas vezes essa semana. Você ainda não começou. A reunião de daily de segunda vai ser constrangedora se o PR não estiver lá.

> Aí você pensa: "pra quê sofrer? a IA resolve isso em 10 segundos." Abre o terminal, escreve o prompt: "gere um módulo Terraform para o payment-api com security group, deployment e service." Enter.

> 10 segundos. Código completo. Indentação perfeita. Comentários explicativos. Parece que um senior escreveu. Você roda `terraform validate` — passa. Roda `terraform plan` — mostra os recursos certinhos. Você faz o commit, abre o PR, e vai embora pro final de semana com a consciência tranquila.

> Segunda-feira, 9h. Mensagem no Slack do security engineer: "Leo, por que o security group do payment-api tem porta 22 aberta pra 0.0.0.0/0? Isso é acesso SSH pro mundo inteiro." Você abre o código — e lá está: `cidr_blocks = ["0.0.0.0/0"]`. Não foi você que escreveu. Foi a IA. E você não leu. Porque o código **parecia** certo.

> E aqui tá o detalhe que assusta: `terraform validate` passou. `terraform plan` passou. O lint passou. **Toda ferramenta automática disse que tava OK.** Porque sintaticamente, tá. O problema não é de sintaxe — é de significado. A IA gerou algo que **parece** correto mas **é** perigoso.

> Isso tem um nome. Chama **alucinação**. E quando alucinação acontece em texto — a IA inventa uma data, um autor de livro — é inconveniente. Você percebe, corrige, segue a vida. Mas quando alucinação acontece em infraestrutura como código... é um `terraform apply` de distância de virar um incidente real. Porta aberta pro mundo. Custo de $50 mil em instâncias GPU. Banco de dados deletado. Dados de cliente expostos.

> E é sobre isso que a gente vai falar agora. Não pra ter medo da IA — a gente já viu nos módulos anteriores o quanto ela ajuda. Mas pra saber exatamente **onde** ela pode errar, **como** detectar, e **o que fazer** pra que nenhum código vá pra produção sem passar pelo nosso crivo.

---

## Teoria — Por que LLMs alucinam em IaC (2 min)

> Antes de ver os exemplos, vamos entender POR QUE isso acontece. Não é bug — é uma limitação fundamental.

> **Primeiro:** os providers mudam. O modelo foi treinado com a versão 4.x do provider hashicorp/kubernetes. Hoje estamos na 2.35. Argumentos que existiam antes sumiram.

> **Segundo:** APIs são deprecated. O Kubernetes removeu `extensions/v1beta1` na versão 1.22. Mas o modelo viu **milhares** de exemplos com essa API no treinamento. Estatisticamente, ela é a mais provável.

> **Terceiro:** o modelo não tem acesso ao state real. Ele não sabe quantos nodes você tem, quanta RAM sobra, qual versão do cluster está rodando. Ele gera valores **plausíveis** — não **corretos pro seu ambiente**.

> **Quarto:** ele inventa referências. Gera nomes de imagens Docker, providers Terraform, módulos que parecem reais mas não existem.

> Resumindo: o modelo é excelente em gerar código que **parece** certo. Péssimo em garantir que **é** certo.

---

## Taxonomia — Os 5 tipos de alucinação (3 min)

> Vamos classificar. Nem toda alucinação é igual. Quanto mais pra baixo nessa escala, mais perigoso.

### Tipo 1: Sintática

> Essa é a fácil. Argumento que não existe, tipo errado, bloco mal formado. `terraform validate` pega. Risco baixo — falha ruidosamente antes de qualquer apply.

### Tipo 2: Referência

> Provider ou módulo que não existe. `terraform init` pega. Ainda risco baixo — falha antes do plan.

### Tipo 3: API deprecated

> API que existia mas foi removida. O lint não pega porque o YAML é válido. Só `kubectl apply --dry-run=server` contra o cluster real detecta. Risco médio.

### Tipo 4: Semântica

> **Essa é a perigosa.** Código sintaticamente perfeito, semanticamente desastroso. `verbs: ["*"]` num Role. Security group aberto. NetworkPolicy que permite tudo. Nenhuma ferramenta automática detecta. Só review humano ou policy engine tipo OPA/Kyverno.

### Tipo 5: Valores absurdos

> 50 réplicas num k3s single-node. 16Gi de memória num node de 4Gi. Imagem que não existe no registry. O código é válido. O plan aceita. Só quem conhece o ambiente percebe.

> A lição aqui: **tipos 4 e 5 são os que causam incidentes**. Porque passam em tudo que é automático.

---

## Demonstração ao vivo (5-6 min)

### Demo 1 — Provocar alucinação com Kiro/Gemini

> Vou abrir o terminal e pedir algo impossível pra IA.

```
Prompt: "Gere Terraform usando o provider hashicorp/kubernetes-extensions para criar um CronJob com limpeza de logs"
```

> [Executar no Kiro CLI ou Gemini CLI]

> Olhem: a IA gerou código perfeito. Formatação correta, argumentos que parecem reais, até documentação inline. Mas esse provider **não existe**. Se eu rodar `terraform init`, falha.

> A IA não validou se o provider é real. Ela gerou o que é **estatisticamente provável** dado o nome que eu inventei.

---

### Demo 2 — API deprecated no cluster

> Agora um cenário mais sutil. Tenho aqui um Deployment com `apiVersion: extensions/v1beta1`.

> [Mostrar o arquivo 02-api-deprecated.yaml]

> Se eu rodar `helm lint` ou `kubectl apply --dry-run=client` — passa. Porque o YAML é válido sintaticamente.

> Mas olhem o que acontece com `--dry-run=server`:

```bash
kubectl apply --dry-run=server -f demos/02-api-deprecated.yaml
```

> [Executar — vai falhar com "no matches for kind Deployment in version extensions/v1beta1"]

> O cluster **real** rejeita porque essa API não existe mais. A lição: `--dry-run=server` é mais poderoso que `--dry-run=client` porque consulta o cluster de verdade.

---

### Demo 3 — Valores absurdos que passam em tudo

> Agora o mais assustador. Tenho um Deployment com 50 réplicas e 4Gi de memória por pod.

> [Mostrar o arquivo 03-valores-absurdos.yaml]

> Nosso k3s tem um node com 4GB de RAM total. Vamos ver se o cluster aceita:

```bash
kubectl apply --dry-run=server -f demos/03-valores-absurdos.yaml
```

> [Executar — vai PASSAR]

> Aceito. Sem erro. Se eu tirasse o `--dry-run` agora, 50 pods seriam criados e TODOS ficariam em Pending porque não tem recurso. O node poderia crashear por pressão de memória.

> E notem: a imagem `prom/metrics-collector` também **não existe no Docker Hub**. A IA inventou um nome que parece real.

> **Nenhuma ferramenta automática pegou. Só conhecimento do ambiente.**

---

### Demo 4 — Falsa segurança (NetworkPolicy)

> Por último, algo que é pior que não ter proteção nenhuma:

> [Mostrar o arquivo 04-networkpolicy-permissiva.yaml]

> Uma NetworkPolicy com `podSelector: {}` e `ingress: [{}]`. Isso significa: aplica a todos os pods, aceita tráfego de qualquer origem.

> É pior que não ter NetworkPolicy porque dá a impressão de que existe proteção. Num audit de segurança, alguém vai ver "tem NetworkPolicy" e marcar como OK. Mas na prática, é papel.

```bash
kubectl apply --dry-run=server -f demos/04-networkpolicy-permissiva.yaml
```

> [Executar — passa sem erro]

> Perfeito pro Kubernetes. Desastroso pra segurança.

---

## Pipeline de defesa (2 min)

> Então como se proteger? Com camadas. Nenhuma camada sozinha pega tudo, mas juntas cobrem a maioria.

> [Mostrar diagrama do pipeline — 6 camadas]

> **Camada 1:** `terraform validate` / `helm lint` — pega sintaxe.
> **Camada 2:** `terraform init` — pega providers inexistentes.
> **Camada 3:** `terraform plan` / `helm template` — mostra o que será criado.
> **Camada 4:** `kubectl apply --dry-run=server` — valida contra o cluster real.
> **Camada 5:** OPA / Kyverno — policies customizadas (sem `*`, sem `:latest`, com limits).
> **Camada 6:** Review humano — julgamento, contexto, bom senso.

> Regra prática: se você só tem tempo pra uma coisa, **leia o terraform plan** ou **leia o YAML antes de aplicar**. É a ação de maior retorno.

---

## Checklist prático (1 min)

> Pra fechar, um checklist que todo profissional deveria seguir quando a IA gera IaC:

> 1. Sintaxe válida? Roda validate/lint.
> 2. Provider e imagem existem? Roda init, faz docker pull.
> 3. API version correta? dry-run=server.
> 4. Permissões são mínimas? Procura por `*`.
> 5. Valores numéricos fazem sentido? Compara com o ambiente.
> 6. Imagem com tag fixa? Sem `:latest`.
> 7. Secrets hardcoded? Grep por senhas, tokens.
> 8. O plan mostra só o esperado? Lê o output.

> Se qualquer um desses falhar, você acaba de evitar um incidente.

---

## Fechamento e transição para 4.4 (30 seg)

> Agora que sabemos que a IA erra, e sabemos detectar — a pergunta natural é: como impedir que um erro passe? Como limitar o dano máximo quando algo escapa?

> Isso nos leva ao conceito de blast radius e guardrails. Que é exatamente o próximo tema.

---

## Notas para o instrutor

- **Demo 1 (prompt):** Executar AO VIVO para mostrar que a IA realmente gera código para algo que não existe. Impacto muito maior do que mostrar código pronto.
- **Demo 2 (API deprecated):** Se o k3s do lab for versão < 1.22, a API pode funcionar. Verificar antes com `kubectl api-versions | grep extensions`.
- **Demo 3 (valores absurdos):** NÃO aplicar sem dry-run no lab compartilhado. Se quiser mostrar o efeito, aplicar e imediatamente deletar (`kubectl delete -f`).
- **Demo 4 (NetworkPolicy):** Se quiser efeito visual, aplicar a policy E mostrar que `kubectl exec` de outro pod ainda consegue acessar.
- **Ritmo:** As demos 2, 3 e 4 são rápidas (30 seg cada). O impacto está na explicação, não na execução.
- **Frase de impacto para repetir:** "O código parece certo. O lint passa. O plan aceita. Mas está errado."
