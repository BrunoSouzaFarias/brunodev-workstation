#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: node — Node.js LTS via NVM
#
# O NVM não é compatível com "set -u/-e"; os comandos nvm rodam em um
# bash separado, sem strict mode, com a saída registrada no log.
# ============================================================================

BDW_MODULE_ID="node"
BDW_MODULE_NOME="Node.js LTS"
BDW_MODULE_DESC="Node.js LTS instalado e definido como padrão via NVM"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS="nvm"

module_compativel() {
  return 0
}

module_verificar() {
  compgen -G "$HOME/.nvm/versions/node/*/bin/node" >/dev/null 2>&1
}

module_instalar() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando Node.js LTS (via NVM)" \
    bash -c 'source "$HOME/.nvm/nvm.sh" && nvm install --lts && nvm alias default "lts/*"'
}

module_configurar() {
  local versao
  versao="$(bash -c 'source "$HOME/.nvm/nvm.sh" >/dev/null 2>&1 && node --version' 2>/dev/null || true)"
  log_sucesso "Node.js ${versao:-LTS} pronto (padrão do NVM)."
}

module_reverter() {
  rm -rf "$HOME/.nvm/versions/node"
  log_aviso "Versões do Node removidas. O NVM foi mantido (módulo nvm)."
}
