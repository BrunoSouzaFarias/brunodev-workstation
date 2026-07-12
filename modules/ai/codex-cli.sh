#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: codex-cli — OpenAI Codex CLI
# ============================================================================

BDW_MODULE_ID="codex-cli"
BDW_MODULE_NOME="Codex CLI"
BDW_MODULE_DESC="Agente de codificação da OpenAI para o terminal"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="node"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe codex || compgen -G "$HOME/.nvm/versions/node/*/bin/codex" >/dev/null 2>&1
}

module_instalar() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando Codex CLI (npm -g)" \
    bash -c 'source "$HOME/.nvm/nvm.sh" && npm install -g @openai/codex'
}

module_configurar() {
  return 0
}

module_reverter() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  bash -c 'source "$HOME/.nvm/nvm.sh" && npm uninstall -g @openai/codex' >/dev/null 2>&1 || true
}
