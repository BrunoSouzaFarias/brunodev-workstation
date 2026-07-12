#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: postgresql — PostgreSQL 16 em container Docker
# ============================================================================

BDW_MODULE_ID="postgresql"
BDW_MODULE_NOME="PostgreSQL"
BDW_MODULE_DESC="PostgreSQL 16 em container (porta 5432, usuário dev)"
BDW_MODULE_CATEGORIA="databases"
BDW_MODULE_DEPS="docker docker-compose"

source "$BDW_ROOT/modules/databases/_comum.sh"

module_compativel() {
  bdw_db_compativel
}

module_verificar() {
  bdw_db_verificar postgres
}

module_instalar() {
  bdw_db_instalar postgres
}

module_configurar() {
  ui_nota "PostgreSQL: localhost:5432 · usuário dev · senha em $_BDW_DB_ENV"
}

module_reverter() {
  bdw_db_reverter postgres
}
