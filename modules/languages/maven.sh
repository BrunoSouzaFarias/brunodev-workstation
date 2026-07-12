#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: maven — Apache Maven via SDKMAN
# ============================================================================

BDW_MODULE_ID="maven"
BDW_MODULE_NOME="Maven"
BDW_MODULE_DESC="Build tool Java (Apache Maven) via SDKMAN"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS="java"

module_compativel() {
  return 0
}

module_verificar() {
  [[ -d "$HOME/.sdkman/candidates/maven/current" ]]
}

module_instalar() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando Maven (sdk install maven)" \
    bash -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install maven </dev/null'
}

module_configurar() {
  return 0
}

module_reverter() {
  rm -rf "$HOME/.sdkman/candidates/maven"
}
