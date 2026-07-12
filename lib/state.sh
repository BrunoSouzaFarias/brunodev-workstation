#!/usr/bin/env bash
# ============================================================================
# lib/state.sh — Manifesto de estado da instalação
#
# Registra em ~/.local/state/brunodev/manifesto os módulos instalados pela
# ferramenta (um por linha: "id|versão|data"). É a fonte de verdade para
# update.sh (reprocessar) e uninstall.sh (reverter), sem heurísticas.
# ============================================================================

[[ -n "${_BDW_LIB_STATE:-}" ]] && return 0
readonly _BDW_LIB_STATE=1

# Garante a existência do arquivo de manifesto.
_estado_garantir() {
  fs_garantir_dir "$(dirname "$BDW_ARQ_MANIFESTO")"
  touch "$BDW_ARQ_MANIFESTO"
}

# Registra um módulo como instalado (substitui entrada anterior).
estado_registrar() {
  local id="$1"
  _estado_garantir
  estado_remover "$id"
  printf '%s|%s|%s\n' "$id" "$BDW_VERSAO" "$(date '+%Y-%m-%d %H:%M:%S')" >>"$BDW_ARQ_MANIFESTO"
}

# Remove um módulo do manifesto.
estado_remover() {
  local id="$1"
  [[ -f "$BDW_ARQ_MANIFESTO" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  grep -v "^${id}|" "$BDW_ARQ_MANIFESTO" >"$tmp" || true
  mv "$tmp" "$BDW_ARQ_MANIFESTO"
}

# Verifica se um módulo está registrado no manifesto.
estado_contem() {
  [[ -f "$BDW_ARQ_MANIFESTO" ]] && grep -q "^${1}|" "$BDW_ARQ_MANIFESTO"
}

# Lista os ids de módulos registrados (um por linha).
estado_listar() {
  [[ -f "$BDW_ARQ_MANIFESTO" ]] || return 0
  cut -d'|' -f1 "$BDW_ARQ_MANIFESTO"
}
