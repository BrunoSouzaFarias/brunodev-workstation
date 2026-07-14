#!/usr/bin/env bash
# ============================================================================
# lib/logger.sh — Sistema de logs do BrunoDev Workstation
#
# Escreve mensagens coloridas no console e, quando um arquivo de log foi
# inicializado via log_iniciar, grava também em disco (sem códigos ANSI).
#
# Níveis: debug < info < aviso < erro. Controlado por BDW_LOG_NIVEL.
# ============================================================================

[[ -n "${_BDW_LIB_LOGGER:-}" ]] && return 0
readonly _BDW_LIB_LOGGER=1

# Nível mínimo exibido no console (debug|info|aviso|erro)
BDW_LOG_NIVEL="${BDW_LOG_NIVEL:-info}"
# Caminho do arquivo de log ativo (vazio = sem gravação em disco)
BDW_ARQ_LOG="${BDW_ARQ_LOG:-}"

# Converte nome do nível em peso numérico para comparação.
_log_peso() {
  case "$1" in
    debug) echo 0 ;;
    info) echo 1 ;;
    aviso) echo 2 ;;
    erro) echo 3 ;;
    *) echo 1 ;;
  esac
}

# Grava uma linha no arquivo de log, se houver arquivo ativo.
_log_arquivo() {
  local nivel="$1" mensagem="$2"
  [[ -z "$BDW_ARQ_LOG" ]] && return 0
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$nivel" "$mensagem" >>"$BDW_ARQ_LOG"
}

# Emite uma mensagem no console (respeitando o nível) e no arquivo.
_log_emitir() {
  local nivel="$1" simbolo="$2" cor="$3" mensagem="$4"
  _log_arquivo "$nivel" "$mensagem"
  (($(_log_peso "$nivel") < $(_log_peso "$BDW_LOG_NIVEL"))) && return 0
  
  if [[ "${BDW_NAO_INTERATIVO:-0}" == "1" ]]; then
    printf '%b%s%b %s %s\n' "$cor" "$simbolo" "$BDW_COR_RESET" "$(date '+%H:%M:%S')" "$mensagem" >&2
  else
    printf '%b%s%b %s\n' "$cor" "$simbolo" "$BDW_COR_RESET" "$mensagem" >&2
  fi
}

log_debug() { _log_emitir debug "·" "$BDW_COR_CINZA" "$*"; }
log_info() { _log_emitir info "→" "$BDW_COR_AZUL" "$*"; }
log_sucesso() { _log_emitir info "✔" "$BDW_COR_VERDE" "$*"; }
log_aviso() { _log_emitir aviso "⚠" "$BDW_COR_AMARELO" "$*"; }
log_erro() { _log_emitir erro "✖" "$BDW_COR_VERMELHO" "$*"; }

# Registra o erro e encerra o processo com código de falha.
log_fatal() {
  log_erro "$*"
  exit 1
}

# Cria o arquivo de log da sessão em BDW_DIR_LOGS e o torna ativo.
# Uso: log_iniciar <prefixo>   (ex: log_iniciar install)
log_iniciar() {
  local prefixo="${1:-sessao}"
  [[ -z "${BDW_DIR_LOGS:-}" ]] && return 0
  mkdir -p "$BDW_DIR_LOGS"
  BDW_ARQ_LOG="$BDW_DIR_LOGS/${prefixo}-$(date '+%Y%m%d-%H%M%S').log"
  export BDW_ARQ_LOG
  _log_arquivo info "===== BrunoDev Workstation v${BDW_VERSAO:-?} — sessão iniciada ====="
  log_debug "Log da sessão: $BDW_ARQ_LOG"
}
