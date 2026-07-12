#!/usr/bin/env bash
# ============================================================================
# lib/progress.sh — Progresso global da instalação (etapa X de N)
# ============================================================================

[[ -n "${_BDW_LIB_PROGRESS:-}" ]] && return 0
readonly _BDW_LIB_PROGRESS=1

_BDW_PROGRESSO_TOTAL=0
_BDW_PROGRESSO_ATUAL=0

# Define o total de etapas da execução atual.
progresso_definir_total() {
  _BDW_PROGRESSO_TOTAL="$1"
  _BDW_PROGRESSO_ATUAL=0
}

# Avança uma etapa e exibe o cabeçalho dela.
# Uso: progresso_passo "Docker Engine"
progresso_passo() {
  ((_BDW_PROGRESSO_ATUAL++)) || true
  printf '\n%b[%d/%d]%b %b%s%b\n' \
    "$BDW_COR_FRACO" "$_BDW_PROGRESSO_ATUAL" "$_BDW_PROGRESSO_TOTAL" "$BDW_COR_RESET" \
    "$BDW_COR_NEGRITO" "$1" "$BDW_COR_RESET"
  _log_arquivo info "--- [$_BDW_PROGRESSO_ATUAL/$_BDW_PROGRESSO_TOTAL] $1 ---"
}

# Exibe uma barra de progresso proporcional ao estado atual.
progresso_barra() {
  local largura=30 preenchido vazio
  ((_BDW_PROGRESSO_TOTAL == 0)) && return 0
  preenchido=$((largura * _BDW_PROGRESSO_ATUAL / _BDW_PROGRESSO_TOTAL))
  vazio=$((largura - preenchido))
  printf '%b[' "$BDW_COR_CIANO"
  printf '%*s' "$preenchido" '' | tr ' ' '█'
  printf '%*s' "$vazio" '' | tr ' ' '░'
  printf ']%b %d%%\n' "$BDW_COR_RESET" $((100 * _BDW_PROGRESSO_ATUAL / _BDW_PROGRESSO_TOTAL))
}
