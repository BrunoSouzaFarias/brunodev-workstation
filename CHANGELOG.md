# Changelog

Este projeto segue [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado

- Fundação: biblioteca compartilhada (`lib/`) com detecção de sistema, abstração de pacotes, runtime de módulos e TUI sobre `gum`.
- Orquestradores `install.sh`, `update.sh` e `uninstall.sh`, com `bootstrap.sh` e `requirements.sh`.
- 40 módulos cobrindo sistema, desenvolvimento, containers, linguagens, bancos de dados, IA, desktop e segurança para Ubuntu 24.04 LTS.
- 12 perfis prontos de instalação (`developer`, `web`, `backend`, `frontend`, `devops`, `ai-engineer`, `data-science`, `android`, `java`, `fullstack`, `completo`, `minimo`).
- Testes unitários (bats-core) e teste de integração E2E em container `ubuntu:24.04`.
- CI com ShellCheck, shfmt, markdownlint e execução automática dos testes.
- Documentação completa: arquitetura, catálogo de módulos, roadmap, FAQ e troubleshooting.

## [1.0.0] — a lançar

Primeira versão pública, suportando Ubuntu 24.04 LTS.
