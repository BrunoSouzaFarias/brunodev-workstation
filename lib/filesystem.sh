#!/usr/bin/env bash
# ============================================================================
# lib/filesystem.sh — Operações seguras de arquivos e diretórios
#
# Toda escrita em arquivo de configuração existente gera backup automático,
# permitindo reverter alterações manualmente ou via rollback.
# ============================================================================

[[ -n "${_BDW_LIB_FILESYSTEM:-}" ]] && return 0
readonly _BDW_LIB_FILESYSTEM=1

# Garante a existência de um diretório.
fs_garantir_dir() {
  mkdir -p "$1"
}

# Cria backup de um arquivo (se existir) antes de sobrescrevê-lo.
# Ecoa o caminho do backup criado, ou nada se o arquivo não existia.
fs_backup_arquivo() {
  local arquivo="$1"
  [[ -f "$arquivo" ]] || return 0
  local backup
  backup="${arquivo}.bak-$(date '+%Y%m%d-%H%M%S')"
  cp -p "$arquivo" "$backup"
  log_debug "Backup criado: $backup"
  printf '%s' "$backup"
}

# Copia um arquivo de configuração preservando o destino em backup.
# Uso: fs_instalar_config <origem> <destino>
fs_instalar_config() {
  local origem="$1" destino="$2"
  [[ -f "$origem" ]] || {
    log_erro "Arquivo de configuração não encontrado: $origem"
    return 1
  }
  fs_garantir_dir "$(dirname "$destino")"
  fs_backup_arquivo "$destino" >/dev/null
  cp "$origem" "$destino"
  log_debug "Configuração instalada: $destino"
}

# Cria/atualiza um link simbólico com backup do destino pré-existente.
fs_link_simbolico() {
  local origem="$1" destino="$2"
  fs_garantir_dir "$(dirname "$destino")"
  if [[ -e "$destino" && ! -L "$destino" ]]; then
    fs_backup_arquivo "$destino" >/dev/null
    rm -f "$destino"
  fi
  ln -sfn "$origem" "$destino"
}

# Acrescenta uma linha a um arquivo apenas se ela ainda não existir.
# Uso: fs_adicionar_linha <arquivo> <linha>
fs_adicionar_linha() {
  local arquivo="$1" linha="$2"
  fs_garantir_dir "$(dirname "$arquivo")"
  touch "$arquivo"
  grep -qxF "$linha" "$arquivo" || printf '%s\n' "$linha" >>"$arquivo"
}

# Escreve conteúdo (stdin) em um arquivo protegido do sistema, com backup.
# Uso: fs_escrever_root <destino> <<< "conteúdo"
fs_escrever_root() {
  local destino="$1"
  if [[ -f "$destino" ]]; then
    como_root cp -p "$destino" "${destino}.bak-$(date '+%Y%m%d-%H%M%S')"
  fi
  como_root install -d "$(dirname "$destino")"
  como_root tee "$destino" >/dev/null
}
