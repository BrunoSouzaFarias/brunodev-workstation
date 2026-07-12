#!/usr/bin/env bash
# ============================================================================
# lib/colors.sh — Paleta de cores ANSI do BrunoDev Workstation
#
# Detecta automaticamente se o terminal suporta cores. Respeita a variável
# de ambiente NO_COLOR (https://no-color.org) e saídas não-interativas.
# ============================================================================

[[ -n "${_BDW_LIB_COLORS:-}" ]] && return 0
readonly _BDW_LIB_COLORS=1

# Verifica se a saída padrão suporta cores.
cores_suportadas() {
  [[ -z "${NO_COLOR:-}" && -t 1 && "${TERM:-}" != "dumb" ]]
}

# As constantes abaixo são consumidas pelos demais arquivos da lib.
# shellcheck disable=SC2034
if cores_suportadas; then
  readonly BDW_COR_RESET=$'\033[0m'
  readonly BDW_COR_NEGRITO=$'\033[1m'
  readonly BDW_COR_FRACO=$'\033[2m'
  readonly BDW_COR_VERMELHO=$'\033[31m'
  readonly BDW_COR_VERDE=$'\033[32m'
  readonly BDW_COR_AMARELO=$'\033[33m'
  readonly BDW_COR_AZUL=$'\033[34m'
  readonly BDW_COR_MAGENTA=$'\033[35m'
  readonly BDW_COR_CIANO=$'\033[36m'
  readonly BDW_COR_CINZA=$'\033[90m'
else
  readonly BDW_COR_RESET=""
  readonly BDW_COR_NEGRITO=""
  readonly BDW_COR_FRACO=""
  readonly BDW_COR_VERMELHO=""
  readonly BDW_COR_VERDE=""
  readonly BDW_COR_AMARELO=""
  readonly BDW_COR_AZUL=""
  readonly BDW_COR_MAGENTA=""
  readonly BDW_COR_CIANO=""
  readonly BDW_COR_CINZA=""
fi
