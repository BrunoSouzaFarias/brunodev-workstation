#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: nvm — Node Version Manager
# ============================================================================

BDW_MODULE_ID="nvm"
BDW_MODULE_NOME="NVM"
BDW_MODULE_DESC="Gerenciador de versões do Node.js"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS=""

# Versão do instalador fixada para downloads reprodutíveis.
_NVM_VERSAO="v0.40.1"

module_compativel() {
  return 0
}

module_verificar() {
  [[ -s "$HOME/.nvm/nvm.sh" ]]
}

module_instalar() {
  rollback_registrar "rm -rf '$HOME/.nvm'"
  spin_executar "Instalando NVM $_NVM_VERSAO" \
    net_executar_script_remoto "https://raw.githubusercontent.com/nvm-sh/nvm/$_NVM_VERSAO/install.sh"
}

module_configurar() {
  # O carregamento no shell é feito pelo zshrc do módulo shell (e pelo
  # próprio instalador do NVM no ~/.bashrc).
  return 0
}

module_reverter() {
  rm -rf "$HOME/.nvm"
  log_aviso "NVM removido. Linhas de carregamento no ~/.bashrc podem ser limpas manualmente."
}
