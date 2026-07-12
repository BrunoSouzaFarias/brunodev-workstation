#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: terminal — Ghostty (emulador de terminal moderno, GPU-accelerated)
#
# O Ghostty não está no APT do Ubuntu 24.04; usamos o .deb do projeto
# comunitário oficial ghostty-ubuntu (recomendado pela documentação do Ghostty).
# ============================================================================

BDW_MODULE_ID="terminal"
BDW_MODULE_NOME="Ghostty"
BDW_MODULE_DESC="Emulador de terminal moderno e acelerado por GPU"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS="sistema"

module_compativel() {
  # Emulador gráfico exige sessão gráfica.
  [[ "${BDW_TEM_GUI:-0}" == "1" ]]
}

module_verificar() {
  comando_existe ghostty && [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config" ]]
}

module_instalar() {
  # Localiza o .deb da última release compatível com a versão do Ubuntu.
  local api="https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest"
  local url
  url="$(curl -fsSL "$api" 2>>"${BDW_ARQ_LOG:-/dev/null}" |
    jq -r --arg filtro "$(arquitetura_release)_${BDW_DISTRO_VERSAO}.deb" \
      '.assets[].browser_download_url | select(endswith($filtro))' | head -n1)"
  [[ -n "$url" && "$url" != "null" ]] ||
    log_fatal "Não encontrei um .deb do Ghostty para Ubuntu $BDW_DISTRO_VERSAO."

  local deb
  deb="$(mktemp --suffix=.deb)"
  net_baixar "$url" "$deb"
  rollback_registrar "pkg_remover ghostty"
  pkg_instalar_deb "$deb"
  rm -f "$deb"
}

module_configurar() {
  fs_instalar_config "$BDW_ROOT/configs/ghostty/config" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
}

module_reverter() {
  pkg_remover ghostty || true
  log_aviso "Configuração ~/.config/ghostty mantida (backups .bak-* disponíveis)."
}
