#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: docker-compose — Plugin Docker Compose v2
# ============================================================================

BDW_MODULE_ID="docker-compose"
BDW_MODULE_NOME="Docker Compose"
BDW_MODULE_DESC="Plugin Compose v2 (docker compose) do repositório oficial"
BDW_MODULE_CATEGORIA="containers"
BDW_MODULE_DEPS="docker"

module_compativel() {
  return 0
}

module_verificar() {
  docker compose version >/dev/null 2>&1
}

module_instalar() {
  pkg_instalar docker-compose-plugin
}

module_configurar() {
  return 0
}

module_reverter() {
  pkg_remover docker-compose-plugin || true
}
