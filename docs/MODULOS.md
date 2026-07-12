# Catálogo de Módulos

Todos os módulos disponíveis na v1.0 (Ubuntu 24.04), organizados por categoria. Use `./install.sh --listar` para ver este catálogo com o status de instalação do seu sistema.

## Sistema

| Módulo | Descrição |
|---|---|
| `sistema` | Atualiza o sistema e instala utilitários essenciais de build e CLI (build-essential, curl, jq, ripgrep, fd, bat...) |

## Desenvolvimento

| Módulo | Descrição |
|---|---|
| `git` | Git + LFS com configuração global (identidade via TUI, aliases e padrões modernos) |
| `ssh` | Chave ed25519 (gerada apenas se não existir), agente e configuração do cliente |
| `github-cli` | Cliente oficial do GitHub (`gh`) para PRs, issues e autenticação |
| `vscode` | Editor com extensões (Copilot, Claude Code, Docker, ESLint...) e settings prontos |
| `terminal` | Ghostty — emulador de terminal moderno e acelerado por GPU |
| `shell` | ZSH como shell padrão, prompt Starship, Fastfetch e aliases |

## Containers

| Módulo | Descrição |
|---|---|
| `docker` | Docker Engine + Buildx via repositório oficial, com grupo `docker` e `daemon.json` |
| `docker-compose` | Plugin Compose v2 (`docker compose`) |
| `podman` | Engine de containers rootless e sem daemon (alternativa ao Docker) |

## Linguagens

| Módulo | Descrição |
|---|---|
| `nvm` | Node Version Manager |
| `node` | Node.js LTS instalado e definido como padrão via NVM |
| `pnpm` | Gerenciador de pacotes Node rápido e eficiente em disco |
| `bun` | Runtime JS/TS com bundler, test runner e gerenciador de pacotes embutidos |
| `python` | Python 3 com venv, pip e pipx para ferramentas isoladas |
| `uv` | Gerenciador de pacotes/projetos Python ultrarrápido (Astral) |
| `java` | JDK atual via SDKMAN, com troca de versões fácil |
| `maven` | Apache Maven via SDKMAN |
| `gradle` | Gradle via SDKMAN |

## Bancos de Dados

Todos rodam como containers Docker (não instalação nativa), com senhas geradas automaticamente e portas expostas apenas em `localhost`.

| Módulo | Descrição |
|---|---|
| `postgresql` | PostgreSQL 16 (porta 5432, usuário `dev`) |
| `redis` | Redis 7 com persistência AOF (porta 6379) |
| `mysql` | MySQL 8.4 (porta 3306, usuário `dev`) |

## Inteligência Artificial

| Módulo | Descrição |
|---|---|
| `claude-code` | Claude Code — CLI de codificação agêntica da Anthropic |
| `gemini-cli` | Gemini CLI — agente de IA do Google para o terminal |
| `codex-cli` | Codex CLI — agente de codificação da OpenAI |
| `openai-cli` | CLI oficial da API da OpenAI (via pipx) |
| `ollama` | Execução local de LLMs, com download opcional de modelos escolhido na TUI |
| `open-webui` | Interface web tipo ChatGPT para o Ollama (`localhost:3000`) |
| `aider` | Pair programming com IA no terminal (via pipx) |
| `continue` | Extensão de IA open source para VS Code, integrável ao Ollama local |

## Desktop

| Módulo | Descrição |
|---|---|
| `apps` | Chrome, Discord, Slack, Telegram, VLC, OBS, Flameshot, Obsidian, Spotify, LibreOffice |
| `fonts` | Nerd Fonts (JetBrainsMono e CascadiaCode) |
| `themes` | Modo escuro e ícones Papirus (requer GNOME) |
| `gnome` | GNOME Tweaks + ajustes de produtividade |
| `kde` | Prévia — suporte completo ao KDE Plasma chega na v2.0 |

## Segurança

| Módulo | Descrição |
|---|---|
| `firewall` | UFW: bloqueia entradas, libera saídas e SSH |
| `fail2ban` | Bane IPs após tentativas repetidas de login SSH |
| `ssh-hardening` | Endurece o servidor SSH (root desabilitado, timeouts, limites de auth) |
| `snapshots` | Timeshift para restauração do sistema |
| `backup` | Backup semanal de documentos e configurações, com rotação |

---

Cada módulo é idempotente (seguro para rodar de novo) e reversível via `./uninstall.sh`. Dados do usuário (chaves SSH, volumes de banco, backups) nunca são apagados automaticamente na reversão — veja as notas de cada módulo em `modules/<categoria>/<id>.sh`.
