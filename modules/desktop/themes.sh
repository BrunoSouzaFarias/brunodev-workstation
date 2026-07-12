#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: themes — Tema escuro e ícones Papirus (GNOME)
# ============================================================================

BDW_MODULE_ID="themes"
BDW_MODULE_NOME="Temas"
BDW_MODULE_DESC="Modo escuro e ícones Papirus para o GNOME"
BDW_MODULE_CATEGORIA="desktop"
BDW_MODULE_DEPS=""

module_compativel() {
  [[ "${BDW_TEM_GUI:-0}" == "1" && "${BDW_DESKTOP:-}" == *GNOME* ]]
}

module_verificar() {
  pkg_existe papirus-icon-theme &&
    [[ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" == *prefer-dark* ]]
}

module_instalar() {
  pkg_instalar papirus-icon-theme
}

module_configurar() {
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
  log_sucesso "Modo escuro e ícones Papirus aplicados."
}

module_reverter() {
  gsettings reset org.gnome.desktop.interface color-scheme 2>/dev/null || true
  gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null || true
  pkg_remover papirus-icon-theme || true
}
