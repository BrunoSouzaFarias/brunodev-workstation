#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: shell — ZSH + Starship + Fastfetch + aliases
# ============================================================================

BDW_MODULE_ID="shell"
BDW_MODULE_NOME="Shell (ZSH + Starship)"
BDW_MODULE_DESC="ZSH como shell padrão, prompt Starship, Fastfetch e aliases"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS=""

_SHELL_MARCADOR="# >>> brunodev-workstation >>>"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe zsh && comando_existe starship && comando_existe fastfetch &&
    grep -q "$_SHELL_MARCADOR" "$HOME/.zshrc" 2>/dev/null
}

module_instalar() {
  pkg_instalar zsh zsh-autosuggestions zsh-syntax-highlighting

  # Starship: instalador oficial (baixado antes de executar, nunca curl|bash).
  if ! comando_existe starship; then
    spin_executar "Instalando Starship" \
      net_executar_script_remoto "https://starship.rs/install.sh" -y
  fi

  # Fastfetch: não está no APT do Ubuntu 24.04; usa o .deb oficial da release.
  if ! comando_existe fastfetch; then
    local deb
    deb="$(mktemp --suffix=.deb)"
    net_baixar "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$(arquitetura_release).deb" "$deb"
    pkg_instalar_deb "$deb"
    rm -f "$deb"
  fi
}

module_configurar() {
  # Arquivos de configuração versionados no repositório.
  fs_instalar_config "$BDW_ROOT/configs/zsh/zshrc" "$HOME/.zshrc"
  fs_instalar_config "$BDW_ROOT/configs/aliases/aliases.sh" "$BDW_DIR_CONFIG/aliases.sh"
  fs_instalar_config "$BDW_ROOT/configs/starship/starship.toml" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
  fs_instalar_config "$BDW_ROOT/configs/fastfetch/config.jsonc" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/config.jsonc"

  # Define o ZSH como shell padrão do usuário.
  local zsh_bin usuario
  zsh_bin="$(command -v zsh)"
  usuario="${SUDO_USER:-$USER}"
  if [[ "$(getent passwd "$usuario" | cut -d: -f7)" != "$zsh_bin" ]]; then
    como_root chsh -s "$zsh_bin" "$usuario" ||
      log_aviso "Não foi possível trocar o shell padrão; rode: chsh -s $zsh_bin"
  fi
  log_sucesso "ZSH configurado como shell padrão de $usuario."
}

module_reverter() {
  # Restaura o backup mais recente do .zshrc, se houver.
  local backup
  backup="$(find "$HOME" -maxdepth 1 -name '.zshrc.bak-*' -printf '%T@ %p\n' 2>/dev/null |
    sort -rn | head -n1 | cut -d' ' -f2- || true)"
  if [[ -n "$backup" ]]; then
    mv "$backup" "$HOME/.zshrc"
  else
    rm -f "$HOME/.zshrc"
  fi
  como_root chsh -s /bin/bash "${SUDO_USER:-$USER}" || true
  rm -f "$BDW_DIR_CONFIG/aliases.sh"
  log_aviso "Shell padrão restaurado para bash. Pacotes zsh/starship/fastfetch mantidos."
}
