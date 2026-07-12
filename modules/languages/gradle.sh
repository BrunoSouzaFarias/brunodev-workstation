#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: gradle — Gradle via SDKMAN
# ============================================================================

BDW_MODULE_ID="gradle"
BDW_MODULE_NOME="Gradle"
BDW_MODULE_DESC="Build tool Java/Kotlin (Gradle) via SDKMAN"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS="java"

module_compativel() {
  return 0
}

module_verificar() {
  [[ -d "$HOME/.sdkman/candidates/gradle/current" ]]
}

module_instalar() {
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando Gradle (sdk install gradle)" \
    bash -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install gradle </dev/null'
}

module_configurar() {
  return 0
}

module_reverter() {
  rm -rf "$HOME/.sdkman/candidates/gradle"
}
