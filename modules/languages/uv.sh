#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: uv — Gerenciador de pacotes/projetos Python ultrarrápido (Astral)
# ============================================================================

BDW_MODULE_ID="uv"
BDW_MODULE_NOME="uv"
BDW_MODULE_DESC="Gerenciador de pacotes e projetos Python ultrarrápido"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS=""

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe uv || [[ -x "$HOME/.local/bin/uv" ]]
}

module_instalar() {
  rollback_registrar "rm -f '$HOME/.local/bin/uv' '$HOME/.local/bin/uvx'"
  spin_executar "Instalando uv" \
    net_executar_script_remoto "https://astral.sh/uv/install.sh"
}

module_configurar() {
  return 0
}

module_reverter() {
  rm -f "$HOME/.local/bin/uv" "$HOME/.local/bin/uvx"
}
