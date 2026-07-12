#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: claude-code — Claude Code (CLI de codificação agêntica da Anthropic)
# ============================================================================

BDW_MODULE_ID="claude-code"
BDW_MODULE_NOME="Claude Code"
BDW_MODULE_DESC="CLI de codificação agêntica da Anthropic (instalador nativo)"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="sistema"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe claude || [[ -x "$HOME/.local/bin/claude" ]]
}

module_instalar() {
  rollback_registrar "rm -f '$HOME/.local/bin/claude'"
  spin_executar "Instalando Claude Code" \
    net_executar_script_remoto "https://claude.ai/install.sh"
}

module_configurar() {
  ui_nota "Para autenticar o Claude Code, rode depois: claude (login no primeiro uso)"
}

module_reverter() {
  rm -f "$HOME/.local/bin/claude"
  log_aviso "Dados e configurações em ~/.claude foram mantidos."
}
