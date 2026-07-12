#!/usr/bin/env bash
# ============================================================================
# lib/validation.sh — Validações de entrada do BrunoDev Workstation
#
# Funções puras: retornam 0 (válido) ou 1 (inválido), sem efeitos colaterais.
# ============================================================================

[[ -n "${_BDW_LIB_VALIDATION:-}" ]] && return 0
readonly _BDW_LIB_VALIDATION=1

# Valida que o valor não é vazio (após remover espaços).
validar_nao_vazio() {
  [[ -n "${1// /}" ]]
}

# Valida um endereço de e-mail em formato básico.
validar_email() {
  [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

# Valida uma URL http(s).
validar_url() {
  [[ "$1" =~ ^https?://[A-Za-z0-9.-]+(:[0-9]+)?(/.*)?$ ]]
}

# Valida um número inteiro não-negativo.
validar_inteiro() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Valida o identificador de um módulo (minúsculas, números e hífens).
validar_id_modulo() {
  [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

# Valida o nome de um perfil (mesmas regras de um id de módulo).
validar_nome_perfil() {
  validar_id_modulo "$1"
}

# Valida um caminho absoluto.
validar_caminho_absoluto() {
  [[ "$1" == /* ]]
}
