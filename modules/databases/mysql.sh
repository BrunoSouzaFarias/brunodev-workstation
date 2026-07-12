#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: mysql — MySQL 8.4 em container Docker
# ============================================================================

BDW_MODULE_ID="mysql"
BDW_MODULE_NOME="MySQL"
BDW_MODULE_DESC="MySQL 8.4 em container (porta 3306, usuário dev)"
BDW_MODULE_CATEGORIA="databases"
BDW_MODULE_DEPS="docker docker-compose"

source "$BDW_ROOT/modules/databases/_comum.sh"

module_compativel() {
  bdw_db_compativel
}

module_verificar() {
  bdw_db_verificar mysql
}

module_instalar() {
  bdw_db_instalar mysql
}

module_configurar() {
  ui_nota "MySQL: localhost:3306 · usuário dev · senha em $_BDW_DB_ENV"
}

module_reverter() {
  bdw_db_reverter mysql
}
