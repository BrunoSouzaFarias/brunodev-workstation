#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: gnome — Ajustes de produtividade para o GNOME
# ============================================================================

BDW_MODULE_ID="gnome"
BDW_MODULE_NOME="GNOME"
BDW_MODULE_DESC="GNOME Tweaks + ajustes de produtividade (botões, touchpad, relógio)"
BDW_MODULE_CATEGORIA="desktop"
BDW_MODULE_DEPS=""

module_compativel() {
  [[ "${BDW_TEM_GUI:-0}" == "1" && "${BDW_DESKTOP:-}" == *GNOME* ]]
}

module_verificar() {
  pkg_existe gnome-tweaks &&
    [[ "$(gsettings get org.gnome.desktop.wm.preferences button-layout 2>/dev/null)" == *minimize,maximize,close* ]]
}

module_instalar() {
  pkg_instalar gnome-tweaks gnome-shell-extension-manager
}

module_configurar() {
  # Botões de janela completos (minimizar/maximizar/fechar).
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
  # Relógio com segundos ocultos e dia da semana visível.
  gsettings set org.gnome.desktop.interface clock-show-weekday true
  # Touchpad: toque para clicar (apenas em laptops).
  if [[ "${BDW_CHASSI:-}" == "laptop" ]]; then
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
  fi
  log_sucesso "Ajustes do GNOME aplicados."
}

module_reverter() {
  gsettings reset org.gnome.desktop.wm.preferences button-layout 2>/dev/null || true
  gsettings reset org.gnome.desktop.interface clock-show-weekday 2>/dev/null || true
  gsettings reset org.gnome.desktop.peripherals.touchpad tap-to-click 2>/dev/null || true
  pkg_remover gnome-tweaks gnome-shell-extension-manager || true
}
