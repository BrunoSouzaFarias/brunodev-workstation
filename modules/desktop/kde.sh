#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: kde — Ajustes para o KDE Plasma
#
# Suporte completo chega junto com as distros KDE na v2.0/v3.0 (ROADMAP).
# O módulo já existe para que perfis e detecção funcionem desde a v1.0.
# ============================================================================

BDW_MODULE_ID="kde"
BDW_MODULE_NOME="KDE Plasma"
BDW_MODULE_DESC="Ajustes para KDE Plasma (prévia — suporte completo na v2.0)"
BDW_MODULE_CATEGORIA="desktop"
BDW_MODULE_DEPS=""

module_compativel() {
  [[ "${BDW_TEM_GUI:-0}" == "1" && "${BDW_DESKTOP:-}" == *KDE* ]]
}

module_verificar() {
  return 1
}

module_instalar() {
  log_info "Suporte ao KDE Plasma está planejado para a v2.0 — nada a fazer por enquanto."
}

module_configurar() {
  return 0
}

module_reverter() {
  return 0
}
