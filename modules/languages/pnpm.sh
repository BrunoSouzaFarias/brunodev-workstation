#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: pnpm — Gerenciador de pacotes rápido para Node.js
# ============================================================================

BDW_MODULE_ID="pnpm"
BDW_MODULE_NOME="PNPM"
BDW_MODULE_DESC="Gerenciador de pacotes Node rápido e eficiente em disco"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS="node"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe pnpm || compgen -G "$HOME/.nvm/versions/node/*/bin/pnpm" >/dev/null 2>&1
}

module_instalar() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando PNPM (npm -g)" \
    bash -c 'source "$HOME/.nvm/nvm.sh" && npm install -g pnpm'
}

module_configurar() {
  return 0
}

module_reverter() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  bash -c 'source "$HOME/.nvm/nvm.sh" && npm uninstall -g pnpm' >/dev/null 2>&1 || true
}
