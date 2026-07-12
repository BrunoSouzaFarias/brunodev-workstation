#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: aider — Programação em par com IA no terminal
# ============================================================================

BDW_MODULE_ID="aider"
BDW_MODULE_NOME="Aider"
BDW_MODULE_DESC="Pair programming com IA no terminal (via pipx)"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="python"
BDW_MODULE_TIMEOUT=2700

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe aider || [[ -x "$HOME/.local/bin/aider" ]]
}

module_instalar() {
  spin_executar "Instalando Aider (pipx)" pipx install aider-chat
}

module_configurar() {
  ui_nota "Aider usa sua chave de API (ex: ANTHROPIC_API_KEY ou OPENAI_API_KEY) — configure no ambiente."
}

module_reverter() {
  executar_logado pipx uninstall aider-chat || true
}
