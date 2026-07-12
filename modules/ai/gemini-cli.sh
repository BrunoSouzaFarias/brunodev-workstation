#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: gemini-cli — Google Gemini CLI
# ============================================================================

BDW_MODULE_ID="gemini-cli"
BDW_MODULE_NOME="Gemini CLI"
BDW_MODULE_DESC="Agente de IA do Google para o terminal"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="node"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe gemini || compgen -G "$HOME/.nvm/versions/node/*/bin/gemini" >/dev/null 2>&1
}

module_instalar() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando Gemini CLI (npm -g)" \
    bash -c 'source "$HOME/.nvm/nvm.sh" && npm install -g @google/gemini-cli'
}

module_configurar() {
  return 0
}

module_reverter() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  bash -c 'source "$HOME/.nvm/nvm.sh" && npm uninstall -g @google/gemini-cli' >/dev/null 2>&1 || true
}
