# Roadmap

## v1.0 — Ubuntu 24.04 LTS (atual)

- [x] Fundação: lib compartilhada, runtime de módulos, TUI com gum
- [x] 40 módulos: sistema, dev, containers, linguagens, bancos, IA, desktop, segurança
- [x] 12 perfis prontos + modo custom
- [x] Detecção automática de hardware e ambiente
- [x] Idempotência, rollback e manifesto de estado
- [x] Testes unitários (bats) e integração E2E em container
- [x] CI (ShellCheck, shfmt, markdownlint, testes)

## v2.0 — Mais distribuições Debian/Fedora-like

- [x] Fedora
- [x] Ultramarine
- [x] Pop!_OS
- [x] Debian
- [x] Backend `dnf` em `lib/packages.sh`
- [x] Suporte completo ao KDE Plasma (o módulo `kde` já existe como prévia)

## v3.0 — Arch e derivadas

- [x] Arch Linux
- [x] EndeavourOS
- [x] CachyOS
- [ ] openSUSE
- [x] Backend `pacman` em `lib/packages.sh` (zypper pendente)

## Ideias em avaliação (sem versão definida)

- Exportar/importar seleção de módulos como arquivo de perfil customizado
- Telemetria opt-in anônima para priorizar módulos mais usados

Sugestões são bem-vindas via [issues](https://github.com/BrunoSouzaFarias/brunodev-workstation/issues) — veja [CONTRIBUTING.md](../CONTRIBUTING.md).
