#!/usr/bin/env bash
# ============================================================================
# lib/init.sh — Carregador central do BrunoDev Workstation
#
# Ponto único de inicialização: resolve o diretório raiz do projeto,
# define constantes globais e carrega toda a biblioteca na ordem correta
# de dependências. Todo script executável deve fazer apenas:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"
# ============================================================================

[[ -n "${_BDW_LIB_INIT:-}" ]] && return 0
readonly _BDW_LIB_INIT=1

# --- Identidade do projeto ---------------------------------------------------
# Constantes consumidas pelos scripts executáveis e demais arquivos da lib.
# shellcheck disable=SC2034
{
  readonly BDW_VERSAO="1.0.0"
  readonly BDW_NOME="BrunoDev Workstation"
  readonly BDW_REPO_URL="https://github.com/BrunoSouzaFarias/brunodev-workstation"
}

# --- Diretório raiz do projeto ----------------------------------------------
# Resolvido a partir da localização deste arquivo (lib/init.sh → raiz).
BDW_ROOT="${BDW_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export BDW_ROOT

# --- Diretórios de dados do usuário (padrão XDG) -----------------------------
export BDW_DIR_DADOS="${BDW_DIR_DADOS:-${XDG_DATA_HOME:-$HOME/.local/share}/brunodev}"
export BDW_DIR_ESTADO="${BDW_DIR_ESTADO:-${XDG_STATE_HOME:-$HOME/.local/state}/brunodev}"
export BDW_DIR_CONFIG="${BDW_DIR_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/brunodev}"
export BDW_DIR_LOGS="${BDW_DIR_LOGS:-$BDW_DIR_ESTADO/logs}"
export BDW_ARQ_MANIFESTO="${BDW_ARQ_MANIFESTO:-$BDW_DIR_ESTADO/manifesto}"

# Binários instalados pela própria ferramenta (ex: gum) têm prioridade no PATH.
[[ ":$PATH:" != *":$BDW_DIR_DADOS/bin:"* ]] && export PATH="$BDW_DIR_DADOS/bin:$PATH"

# --- Modo de execução ---------------------------------------------------------
# BDW_NAO_INTERATIVO=1 desativa TUI e prompts (uso em CI e containers).
export BDW_NAO_INTERATIVO="${BDW_NAO_INTERATIVO:-0}"

# --- Carga da biblioteca (ordem de dependência) -------------------------------
# Núcleo
source "$BDW_ROOT/lib/colors.sh"
source "$BDW_ROOT/lib/logger.sh"
source "$BDW_ROOT/lib/utils.sh"
source "$BDW_ROOT/lib/validation.sh"
source "$BDW_ROOT/lib/spinner.sh"
source "$BDW_ROOT/lib/progress.sh"
