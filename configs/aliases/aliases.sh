# shellcheck shell=bash
# ============================================================================
# BrunoDev Workstation — aliases
# Compatível com bash e zsh.
# ============================================================================

# Navegação e listagem
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Git
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'

# Sistema
alias atualizar='sudo apt update && sudo apt upgrade -y'
alias portas='ss -tulpn'
alias meuip='curl -s https://ifconfig.me && echo'
alias espaco='df -h ~ | tail -1'

# Utilitários modernos (instalados pelo módulo sistema)
command -v batcat >/dev/null && alias cat='batcat --paging=never --style=plain'
command -v fdfind >/dev/null && alias fd='fdfind'

# BrunoDev Workstation
alias bdw-atualizar='bash "${XDG_DATA_HOME:-$HOME/.local/share}/brunodev/workstation/update.sh" 2>/dev/null || echo "use ./update.sh no clone do projeto"'
