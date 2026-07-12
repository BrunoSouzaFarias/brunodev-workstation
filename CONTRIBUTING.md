# Contribuindo com o BrunoDev Workstation

Obrigado pelo interesse em contribuir! Este guia cobre o essencial para começar.

## Ambiente de desenvolvimento

Requisitos: `bash` 4+, `git`, `docker` (para o teste de integração), `shellcheck` e `shfmt` (para lint).

```bash
git clone https://github.com/BrunoSouzaFarias/brunodev-workstation
cd brunodev-workstation
./scripts/lint.sh          # shellcheck + shfmt em todo o repositório
./tests/run-tests.sh       # testes unitários (bats-core é baixado automaticamente)
./tests/run-tests.sh --integracao   # E2E completo dentro de ubuntu:24.04 (requer Docker)
```

## Padrões de código

- **Idioma:** código, comentários, docs e mensagens da TUI em português. Nomes de arquivo seguem os nomes convencionais do projeto (`install.sh`, `logger.sh`...).
- **Strict mode obrigatório:** todo script novo começa com `set -Eeuo pipefail`.
- **Nomenclatura de funções:** `namespace_verbo` (ex: `log_info`, `distro_detectar`, `pkg_instalar`).
- **Sem comentários óbvios.** Comente apenas o que não é evidente pelo código (uma decisão não óbvia, uma limitação de uma ferramenta externa).
- **Formatação:** `shfmt -i 2 -ci` (2 espaços, indentação de `case` alinhada). Rode `./scripts/format.sh` antes de commitar.
- **Lint:** `shellcheck -x` não pode reportar erros. Avisos justificados usam `# shellcheck disable=SCxxxx  # motivo`.

## Adicionando um novo módulo

1. Escolha a categoria (`system`, `dev`, `containers`, `languages`, `databases`, `ai`, `desktop`, `security`) e crie `modules/<categoria>/<id>.sh`.
2. Implemente os metadados e os cinco verbos obrigatórios — veja [docs/ARQUITETURA.md](docs/ARQUITETURA.md#o-contrato-de-módulo) para o contrato completo e exemplos de módulos existentes em `modules/`.
3. Garanta idempotência real: `module_verificar` deve detectar corretamente uma instalação já feita.
4. Garanta reversibilidade: `module_reverter` desfaz o que foi feito, mas **nunca apaga dados do usuário** (volumes, chaves, backups) — apenas avisa que foram preservados.
5. Se o módulo depende de outro, declare em `BDW_MODULE_DEPS="id1 id2"`.
6. Rode `./scripts/lint.sh` e `./tests/run-tests.sh`.
7. Adicione o módulo a algum perfil relevante em `configs/profiles/*.list`, se fizer sentido.
8. Atualize `docs/MODULOS.md` com a nova entrada.

## Testando manualmente

O jeito mais seguro de testar sem afetar sua própria máquina:

```bash
docker run -it --rm -v "$PWD":/opt/bdw:ro ubuntu:24.04 bash
# dentro do container:
apt-get update -qq && apt-get install -y -qq curl git sudo
cp -r /opt/bdw ~/bdw && cd ~/bdw
./install.sh --modulos <seu-modulo> --sim
```

## Commits e Pull Requests

- Commits seguem [Conventional Commits](https://www.conventionalcommits.org/) em português: `feat(escopo): mensagem`, `fix(escopo): mensagem`, `docs: mensagem`, `refactor(escopo): mensagem`.
- Um PR por funcionalidade/correção. Preencha o checklist do template de PR.
- CI precisa passar (ShellCheck, shfmt, markdownlint, testes unitários e integração).

## Reportando bugs e sugerindo melhorias

Use os templates de issue do GitHub — eles pedem as informações mínimas para reproduzir o problema (versão, distro, log da sessão).
