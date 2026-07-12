#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: python — Python 3 + venv + pipx
# ============================================================================

BDW_MODULE_ID="python"
BDW_MODULE_NOME="Python 3"
BDW_MODULE_DESC="Python 3 com venv, pip e pipx para ferramentas isoladas"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS=""

_PYTHON_PACOTES=(python3 python3-venv python3-pip pipx)

module_compativel() {
  return 0
}

module_verificar() {
  local pacote
  for pacote in "${_PYTHON_PACOTES[@]}"; do
    pkg_existe "$pacote" || return 1
  done
}

module_instalar() {
  pkg_instalar "${_PYTHON_PACOTES[@]}"
}

module_configurar() {
  executar_logado pipx ensurepath || true
}

module_reverter() {
  # python3 é vital para o próprio sistema operacional — nunca remover.
  pkg_remover pipx || true
  log_aviso "python3/pip/venv mantidos: são dependências do próprio Ubuntu."
}
