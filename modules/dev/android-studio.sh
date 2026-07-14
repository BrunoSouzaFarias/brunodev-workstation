#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================================
# Módulo: android-studio
# ============================================================================

BDW_MODULE_ID="android-studio"
BDW_MODULE_NOME="Android Studio"
BDW_MODULE_DESC="IDE oficial para desenvolvimento Android via Flatpak"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS="sistema,java"

module_compativel() {
  [[ "${BDW_CONTAINER:-0}" == "0" ]]
}

module_verificar() {
  flatpak_existe "com.google.AndroidStudio"
}

module_instalar() {
  flatpak_garantir
  flatpak_instalar "com.google.AndroidStudio"
}

module_configurar() {
  ui_nota "Android Studio instalado. Configure o SDK no primeiro boot."
}

module_reverter() {
  flatpak uninstall -y com.google.AndroidStudio || true
}