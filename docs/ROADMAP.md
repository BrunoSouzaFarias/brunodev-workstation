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

- [ ] Fedora
- [ ] Ultramarine
- [ ] Pop!_OS
- [ ] Debian
- [ ] Backend `dnf` em `lib/packages.sh`
- [ ] Suporte completo ao KDE Plasma (o módulo `kde` já existe como prévia)
- [ ] Módulo Android Studio

## v3.0 — Arch e derivadas

- [ ] Arch Linux
- [ ] EndeavourOS
- [ ] CachyOS
- [ ] openSUSE
- [ ] Backend `pacman`/`zypper` em `lib/packages.sh`

## Ideias em avaliação (sem versão definida)

- Suporte a Kubernetes (k3s/kind) como módulo DevOps
- Modo "dry-run" (`--simular`) que mostra o plano sem executar nada
- Exportar/importar seleção de módulos como arquivo de perfil customizado
- Telemetria opt-in anônima para priorizar módulos mais usados

Sugestões são bem-vindas via [issues](https://github.com/BrunoSouzaFarias/brunodev-workstation/issues) — veja [CONTRIBUTING.md](../CONTRIBUTING.md).
