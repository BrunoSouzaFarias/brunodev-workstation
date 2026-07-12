#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: redis — Redis 7 em container Docker
# ============================================================================

BDW_MODULE_ID="redis"
BDW_MODULE_NOME="Redis"
BDW_MODULE_DESC="Redis 7 em container (porta 6379, persistência AOF)"
BDW_MODULE_CATEGORIA="databases"
BDW_MODULE_DEPS="docker docker-compose"

source "$BDW_ROOT/modules/databases/_comum.sh"

module_compativel() {
  bdw_db_compativel
}

module_verificar() {
  bdw_db_verificar redis
}

module_instalar() {
  bdw_db_instalar redis
}

module_configurar() {
  ui_nota "Redis: localhost:6379 (sem senha — acessível apenas em localhost)"
}

module_reverter() {
  bdw_db_reverter redis
}
