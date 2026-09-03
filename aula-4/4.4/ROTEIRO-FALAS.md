# Roteiro de Falas — Aula 4.4: Blast Radius e Guardrails

## Tempo estimado: 12-15 minutos

---

## Abertura (2 min)

> Na 4.3 vimos que a IA alucina. Que ela gera código que parece certo mas pode ser perigoso. E aprendemos a detectar isso com validações e review humano.

> Mas e se a IA não estiver só gerando código para você colar? E se ela estiver EXECUTANDO? Lembram da 4.1 — agentes executam ações no mundo real. Então a pergunta agora é: o que acontece quando um agente erra?

> Vou dar um exemplo concreto. Terça-feira, 14h. O time configurou um agente que monitora disco e faz auto-remediação. Alerta dispara: "disk usage acima de 80% no namespace production." O agente pensa: "preciso liberar espaço." E decide executar: `kubectl delete pvc --all -n production`.

> Pausa. Pensem no que acabou de acontecer. Todos os Persistent Volume Claims do namespace production — deletados. Dados de clientes. Bancos de dados. Arquivos de upload. Tudo.

> O post-mortem vai dizer: "o agente fez exatamente o que foi mandado — liberar disco." E tecnicamente, liberou. Mas ninguém definiu o LIMITE do que ele podia fazer. Ninguém se perguntou: "se essa ação der errado, qual é o dano máximo possível?"

> Essa pergunta — "qual é o dano máximo?" — é o conceito de blast radius. E as proteções que colocamos entre a decisão da IA e a execução real se chamam guardrails. É disso que vamos falar agora.

---

## Conceito: Blast Radius (2 min)

> Blast radius vem da engenharia militar — é a área de destruição de uma explosão. Em infra, é o escopo máximo de dano que uma ação pode causar se der errado.

> Vamos mapear:

> `kubectl get pods` — blast radius ZERO. É read-only. Não importa se a IA errou a query, nada muda no cluster.

> `kubectl apply -n test` — blast radius limitado ao namespace de teste. Se der errado, pods de teste quebram. Ninguém perde o sono.

> `terraform apply` em produção — blast radius: infraestrutura de produção inteira. Se der errado, serviços fora, possível perda de dados.

> `kubectl delete namespace production` — blast radius máximo. Todos os workloads, services, PVCs, configmaps — destruídos.

> A regra é simples: blast radius determina quanta proteção é necessária. Ação read-only? Livre. Delete em produção? Precisa de múltiplas camadas de aprovação.

---

## As 5 camadas de guardrails (3 min)

> Guardrails são as proteções entre "a IA decidiu" e "a ação executou". São 5 camadas, da mais básica à mais sofisticada:

### Camada 1: Sandboxing

> É o que estamos fazendo neste curso. O k3s é um sandbox. Podemos destruir tudo e recriar em 2 minutos. O erro aqui é grátis. Essa é a primeira regra: TODO código gerado por IA é testado num ambiente onde errar não custa nada. SEMPRE.

### Camada 2: Dry-run

> Antes de aplicar qualquer coisa, mostrar o que VAI acontecer. `terraform plan`. `kubectl apply --dry-run=server`. `helm install --dry-run`. Custo zero. 5 segundos. Pega 80% dos problemas. Não existe motivo para pular.

### Camada 3: Aprovação humana

> O agente propõe. O humano decide. Nunca o contrário. O agente mostra: "vou fazer X. Blast radius: Y. Reversível: sim/não. Aprovar?" E espera. Se o humano diz não, nada acontece.

### Camada 4: Monitoramento pós-ação

> Aplicou? Verifica. O pod subiu? O health check responde? O service está acessível? Se sim, segue. Se não, aciona a camada 5.

### Camada 5: Rollback automático

> Se o monitoramento detecta falha, volta pra versão anterior. Sem esperar humano. `helm rollback`. `kubectl rollout undo`. Automaticamente. Porque às 3h da manhã, você não quer depender de alguém acordar para apertar um botão.

> Notem: as camadas se complementam. Sandbox contém o erro. Dry-run previne o erro. Aprovação filtra o erro. Monitoramento detecta o erro. Rollback reverte o erro.

---

## Demonstração ao vivo (5-6 min)

### Demo 1 — Setup do ambiente

> Primeiro vou criar um namespace com 2 deployments e um PVC. Isso simula um ambiente onde o agente vai atuar.

```bash
./run-demos.sh setup
```

> [Executar e mostrar os pods rodando]

---

### Demo 2 — Dry-run: vendo o futuro sem aplicar

> Agora vou mostrar como dry-run funciona como guardrail.

```bash
./03-dry-run.sh
```

> [Executar]

> Olhem: dry-run=server consultou o cluster real. Validou permissões, quotas, APIs. Mas não aplicou NADA. Zero blast radius.

> E no final, simulei o que aconteceria se eu deletasse o namespace inteiro. O cluster me mostra: "sim, eu DELETARIA tudo." Mas como é dry-run, nada foi destruído.

> Isso é o que um agente BEM construído faz: roda dry-run ANTES de executar. E mostra o resultado pro humano aprovar.

---

### Demo 3 — Aprovação humana: o gate entre IA e ação

> Agora vou simular um agente que propõe escalar um deployment.

```bash
./04-aprovacao-humana.sh
```

> [Executar — mostrar a proposta e o prompt de aprovação]

> Olhem a estrutura: o agente calculou o blast radius ("deployment app-a apenas"), disse se é reversível ("sim"), e está ESPERANDO. Ele não faz nada até eu dizer sim.

> [Aprovar e mostrar o resultado]

> Simples, mas poderoso. Essa camada de aprovação impede que um LLM que decidiu errado cause dano. A decisão final é sempre humana.

---

### Demo 4 — Rollback automático: falha detectada, reverte sozinho

> Essa é a mais impressionante. Vou simular um deploy ruim — imagem que não existe. O script vai detectar que o health check falhou e fazer rollback automaticamente.

```bash
./05-rollback-automatico.sh
```

> [Executar — vai tentar deploy, falhar, e reverter]

> Olhem o que aconteceu: fez deploy de uma versão quebrada. O rollout status detectou que os pods não ficaram Ready em 30 segundos. Automaticamente fez `kubectl rollout undo`. O serviço voltou para a versão anterior.

> Na vida real, isso significa: se um agente fizer um deploy ruim às 3h da manhã, o sistema se recupera sozinho antes de qualquer humano acordar.

---

## Menor privilégio para agentes (1 min)

> Por último, RBAC. Mesmo que o agente decida fazer algo perigoso, se ele não tem permissão, o Kubernetes bloqueia.

> [Mostrar arquivo 02-rbac-menor-privilegio.yaml]

> Olhem a diferença: o role "agente-permissivo" dá `resources: *` e `verbs: *`. O agente pode fazer TUDO. Se ele alucinar e decidir deletar um PVC, consegue.

> Já o role "agente-investigador" só pode `get` e `list`. Ele pode OLHAR tudo, mas não pode MUDAR nada. Mesmo que o LLM diga "delete esse pod", a API retorna "forbidden".

> E o "agente-remediador" pode deletar pods (pra restart) e escalar deployments. Mas não pode tocar em PVCs, secrets ou namespaces. Blast radius limitado por RBAC.

> Regra prática: dê ao agente EXATAMENTE o que ele precisa. Nada mais.

---

## Fechamento e transição para 4.5 (30 seg)

> Recapitulando: blast radius define quanto proteger. As 5 camadas — sandbox, dry-run, aprovação, monitoramento, rollback — protegem proporcionalmente.

> Agora que sabemos construir proteções técnicas, a pergunta final é: como organizar isso no time? Quem define as políticas? Quem é responsável quando a IA erra? Como medimos se está funcionando?

> Isso é governança. E é o tema de fechamento da aula.

---

## Notas para o instrutor

- **Setup obrigatório:** Rodar `./run-demos.sh setup` ANTES de iniciar a 4.4. Pods precisam de ~30s para ficar Ready.
- **Demo 4 (aprovação):** É interativa! Não esqueça de digitar "s" ao vivo. Se digitar "n", mostra o bloqueio — pode ser útil mostrar os dois caminhos.
- **Demo 5 (rollback):** Leva ~30-40s por causa do timeout. Avise os alunos: "vou esperar o timeout para mostrar que o rollback é automático." Não pule — a espera é didática.
- **RBAC:** Se quiser demo ao vivo, aplique os roles e tente executar um `kubectl delete pvc` com a ServiceAccount limitada para mostrar o "forbidden".
- **Cleanup:** Rodar `./run-demos.sh cleanup` ao final ou antes da 4.5.
- **Frase de impacto:** "Dry-run é 5 segundos. Incidente é 5 horas. Não existe motivo para pular."
