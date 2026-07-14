#!/usr/bin/env bash
# ============================================================================
# lib/progress.sh — Progresso global da instalação (etapa X de N)
# ============================================================================

[[ -n "${_BDW_LIB_PROGRESS:-}" ]] && return 0
readonly _BDW_LIB_PROGRESS=1

_BDW_PROGRESSO_TOTAL=0
_BDW_PROGRESSO_ATUAL=0
_BDW_PROGRESSO_INICIO=0
_BDW_PROGRESSO_ULTIMO_PASSO=0

# Define o total de etapas da execução atual.
progresso_definir_total() {
  _BDW_PROGRESSO_TOTAL="$1"
  _BDW_PROGRESSO_ATUAL=0
  _BDW_PROGRESSO_INICIO="$(date +%s)"
  _BDW_PROGRESSO_ULTIMO_PASSO="$_BDW_PROGRESSO_INICIO"
}

# Formata segundos em "Xm Ys"
_progresso_formatar_tempo() {
  local s="$1"
  if ((s >= 60)); then
    printf '%dm %ds' $((s / 60)) $((s % 60))
  else
    printf '%ds' "$s"
  fi
}

# Avança uma etapa e exibe o cabeçalho dela com ETA estimado.
# Uso: progresso_passo "Docker Engine"
progresso_passo() {
  ((_BDW_PROGRESSO_ATUAL++)) || true
  local agora eta_str=""
  agora="$(date +%s)"

  if ((_BDW_PROGRESSO_ATUAL > 1 && _BDW_PROGRESSO_TOTAL > 0)); then
    local decorrido=$(( agora - _BDW_PROGRESSO_INICIO ))
    local restantes=$(( _BDW_PROGRESSO_TOTAL - _BDW_PROGRESSO_ATUAL + 1 ))
    local media=$(( decorrido / (_BDW_PROGRESSO_ATUAL - 1) ))
    local eta=$(( media * restantes ))
    eta_str=" $(printf '%b≈ %s restantes%b' "$BDW_COR_CINZA" "$(_progresso_formatar_tempo $eta)" "$BDW_COR_RESET")"
  fi

  _BDW_PROGRESSO_ULTIMO_PASSO="$agora"
  printf '\n%b[%d/%d]%b %b%s%b%s\n' \
    "$BDW_COR_FRACO" "$_BDW_PROGRESSO_ATUAL" "$_BDW_PROGRESSO_TOTAL" "$BDW_COR_RESET" \
    "$BDW_COR_NEGRITO" "$1" "$BDW_COR_RESET" "$eta_str"
  _log_arquivo info "--- [$_BDW_PROGRESSO_ATUAL/$_BDW_PROGRESSO_TOTAL] $1 ---"
}

# Exibe uma barra de progresso proporcional ao estado atual, com tempo decorrido.
progresso_barra() {
  local largura=30 preenchido vazio
  ((_BDW_PROGRESSO_TOTAL == 0)) && return 0
  preenchido=$((largura * _BDW_PROGRESSO_ATUAL / _BDW_PROGRESSO_TOTAL))
  vazio=$((largura - preenchido))
  local decorrido=$(( $(date +%s) - _BDW_PROGRESSO_INICIO ))
  printf '%b[' "$BDW_COR_CIANO"
  printf '%*s' "$preenchido" '' | tr ' ' '█'
  printf '%*s' "$vazio" '' | tr ' ' '░'
  printf ']%b %d%% %b(%s)%b\n' "$BDW_COR_RESET" \
    $((100 * _BDW_PROGRESSO_ATUAL / _BDW_PROGRESSO_TOTAL)) \
    "$BDW_COR_CINZA" "$(_progresso_formatar_tempo $decorrido)" "$BDW_COR_RESET"
}
