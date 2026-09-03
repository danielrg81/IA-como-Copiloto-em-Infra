# Demo: Gerar Dockerfile com prompt preenchido

## Prompt preenchido (self-contained)

```
Papel: Engenheiro DevOps sênior especializado em containers.

Contexto: Demo de aula, preciso de um Dockerfile self-contained que já inclua o código da aplicação embutido (sem depender de arquivos externos).

Gere um Dockerfile otimizado que:
- Contenha uma app Python Flask com um endpoint GET / que retorne "ok"
- Runtime: Python 3.12
- Porta: 5000
- O código da app e requirements.txt devem ser criados DENTRO do Dockerfile (sem COPY de arquivos locais)

Restrições: Multi-stage, alpine, non-root, sem ferramentas de debug.
Formato: Apenas o Dockerfile, pronto para buildar sem nenhum arquivo adicional.
```

## Comandos para executar

```bash
# 1. Salvar o Dockerfile gerado pela IA (app já está embutida)
mkdir -p /tmp/demo-flask && cd /tmp/demo-flask
# (colar o Dockerfile gerado aqui)
vi Dockerfile

# 2. Buildar a imagem
docker build -t demo-flask:1.0 .

# 3. Testar localmente
docker run -d --name demo-flask -p 5000:5000 demo-flask:1.0
curl http://localhost:5000

# 4. Validar segurança (non-root, sem debug tools)
docker exec demo-flask whoami        # esperado: appuser (não root)
docker exec demo-flask which gcc     # esperado: não encontrado

# 5. Limpar
docker stop demo-flask && docker rm demo-flask
```
