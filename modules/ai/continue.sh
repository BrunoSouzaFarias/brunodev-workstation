#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: continue — Assistente de IA open source para o VS Code
# ============================================================================

BDW_MODULE_ID="continue"
BDW_MODULE_NOME="Continue.dev"
BDW_MODULE_DESC="Extensão de IA open source para VS Code (funciona com Ollama)"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="vscode"

module_compativel() {
  [[ "${BDW_TEM_GUI:-0}" == "1" ]] && comando_existe code
}

module_verificar() {
  code --list-extensions 2>/dev/null | grep -qi '^continue\.continue$'
}

module_instalar() {
  spin_executar "Instalando extensão Continue" \
    code --install-extension continue.continue --force
}

module_configurar() {
  ui_nota "Continue: configure seu provedor (Ollama local ou API) no painel da extensão."
}

module_reverter() {
  executar_logado code --uninstall-extension continue.continue || true
}
