#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: apps — Aplicativos desktop essenciais
# ============================================================================

BDW_MODULE_ID="apps"
BDW_MODULE_NOME="Apps Desktop"
BDW_MODULE_DESC="Chrome, Discord, Slack, Telegram, VLC, OBS, Spotify, Obsidian e mais"
BDW_MODULE_CATEGORIA="desktop"
BDW_MODULE_DEPS="sistema"
BDW_MODULE_TIMEOUT=3600

# Apps por origem de instalação.
_APPS_APT=(vlc obs-studio flameshot libreoffice)
_APPS_FLATPAK=(
  com.discordapp.Discord
  com.slack.Slack
  org.telegram.desktop
  md.obsidian.Obsidian
  com.spotify.Client
)

module_compativel() {
  [[ "${BDW_TEM_GUI:-0}" == "1" ]]
}

module_verificar() {
  # Considera instalado quando o Chrome e todos os apps das listas existem.
  pkg_existe google-chrome-stable || return 1
  local item
  for item in "${_APPS_APT[@]}"; do
    pkg_existe "$item" || return 1
  done
  for item in "${_APPS_FLATPAK[@]}"; do
    flatpak_existe "$item" || return 1
  done
}

module_instalar() {
  # Google Chrome via .deb oficial.
  if ! pkg_existe google-chrome-stable; then
    local deb
    deb="$(mktemp --suffix=.deb)"
    net_baixar "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "$deb"
    pkg_instalar_deb "$deb"
    rm -f "$deb"
  fi

  pkg_instalar "${_APPS_APT[@]}"

  flatpak_garantir
  local app
  for app in "${_APPS_FLATPAK[@]}"; do
    flatpak_instalar "$app" || log_aviso "Falha ao instalar $app (continuando)."
  done
}

module_configurar() {
  return 0
}

module_reverter() {
  pkg_remover google-chrome-stable "${_APPS_APT[@]}" || true
  local app
  for app in "${_APPS_FLATPAK[@]}"; do
    executar_logado como_root flatpak uninstall -y "$app" || true
  done
}
