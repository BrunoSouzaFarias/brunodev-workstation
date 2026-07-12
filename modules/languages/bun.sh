#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: bun — Runtime JavaScript tudo-em-um
# ============================================================================

BDW_MODULE_ID="bun"
BDW_MODULE_NOME="Bun"
BDW_MODULE_DESC="Runtime JS/TS rápido com bundler, test runner e gerenciador de pacotes"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS="sistema"

module_compativel() {
  return 0
}

module_verificar() {
  [[ -x "$HOME/.bun/bin/bun" ]]
}

module_instalar() {
  rollback_registrar "rm -rf '$HOME/.bun'"
  spin_executar "Instalando Bun" \
    net_executar_script_remoto "https://bun.sh/install"
}

module_configurar() {
  # O PATH do Bun é carregado pelo zshrc do módulo shell.
  return 0
}

module_reverter() {
  rm -rf "$HOME/.bun"
}
