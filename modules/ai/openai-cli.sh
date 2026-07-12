#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: openai-cli — CLI oficial da API da OpenAI (Python)
# ============================================================================

BDW_MODULE_ID="openai-cli"
BDW_MODULE_NOME="OpenAI CLI"
BDW_MODULE_DESC="CLI oficial da API da OpenAI (via pipx)"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="python"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe openai || [[ -x "$HOME/.local/bin/openai" ]]
}

module_instalar() {
  spin_executar "Instalando OpenAI CLI (pipx)" pipx install openai
}

module_configurar() {
  return 0
}

module_reverter() {
  executar_logado pipx uninstall openai || true
}
