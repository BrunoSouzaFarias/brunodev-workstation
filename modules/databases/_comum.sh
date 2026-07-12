#!/usr/bin/env bash
# ============================================================================
# Helper compartilhado dos módulos de banco de dados (não é um módulo).
#
# Os bancos rodam como containers Docker definidos em
# configs/docker/databases.compose.yml, com senhas geradas automaticamente
# e portas expostas apenas em localhost.
# ============================================================================

_BDW_DB_COMPOSE="$BDW_DIR_DADOS/docker/databases.compose.yml"
_BDW_DB_ENV="$BDW_DIR_CONFIG/databases.env"

# Executa docker compose com o arquivo e env dos bancos.
# Usa sudo pois o grupo docker pode ainda não valer na sessão atual.
bdw_db_compose() {
  como_root docker compose -f "$_BDW_DB_COMPOSE" --env-file "$_BDW_DB_ENV" "$@"
}

# Compatibilidade comum: exige o daemon Docker acessível.
bdw_db_compativel() {
  como_root docker info >/dev/null 2>&1
}

# Garante compose file instalado e env com senhas geradas (chmod 600).
bdw_db_preparar() {
  fs_instalar_config "$BDW_ROOT/configs/docker/databases.compose.yml" "$_BDW_DB_COMPOSE"

  if [[ ! -f "$_BDW_DB_ENV" ]]; then
    fs_garantir_dir "$(dirname "$_BDW_DB_ENV")"
    cat >"$_BDW_DB_ENV" <<ENV
# Senhas dos bancos de desenvolvimento — geradas pelo BrunoDev Workstation
BDW_POSTGRES_SENHA=$(gerar_senha 20)
BDW_MYSQL_SENHA=$(gerar_senha 20)
ENV
    chmod 600 "$_BDW_DB_ENV"
    log_sucesso "Senhas geradas em $_BDW_DB_ENV (usuário: dev)"
  fi
}

# Verifica se o container de um serviço está de pé.
bdw_db_verificar() {
  local servico="$1"
  como_root docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "bdw-$servico"
}

# Sobe um serviço específico do compose.
bdw_db_instalar() {
  local servico="$1"
  bdw_db_preparar
  rollback_registrar "bdw_db_compose rm -sf '$servico'"
  spin_executar "Subindo container do $servico" bdw_db_compose up -d --wait "$servico"
}

# Para e remove o container de um serviço (volumes preservados).
bdw_db_reverter() {
  local servico="$1"
  if [[ -f "$_BDW_DB_COMPOSE" ]]; then
    bdw_db_compose rm -sf "$servico" >/dev/null 2>&1 || true
  fi
  log_aviso "Volume de dados do $servico foi MANTIDO (docker volume ls | grep bdw)."
}
