#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: snapshots — Timeshift (snapshots do sistema)
# ============================================================================

BDW_MODULE_ID="snapshots"
BDW_MODULE_NOME="Snapshots (Timeshift)"
BDW_MODULE_DESC="Snapshots do sistema para restauração após problemas"
BDW_MODULE_CATEGORIA="security"
BDW_MODULE_DEPS=""

module_compativel() {
  # Snapshots exigem um sistema real (não containers).
  [[ "${BDW_CONTAINER:-0}" == "0" ]]
}

module_verificar() {
  pkg_existe timeshift
}

module_instalar() {
  pkg_instalar timeshift
}

module_configurar() {
  ui_nota "Timeshift instalado. Crie o primeiro snapshot: sudo timeshift --create --comments 'workstation pronta'"
}

module_reverter() {
  pkg_remover timeshift || true
  log_aviso "Snapshots existentes em /timeshift foram MANTIDOS."
}
