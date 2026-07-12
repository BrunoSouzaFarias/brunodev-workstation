#!/usr/bin/env bash
# ============================================================================
# lib/cpu.sh — Detecção de CPU
#
# Preenche BDW_CPU_{MODELO,NUCLEOS,ARQ} a partir de /proc/cpuinfo.
# Em testes, o arquivo pode ser substituído via BDW_MOCK_CPUINFO.
# ============================================================================

[[ -n "${_BDW_LIB_CPU:-}" ]] && return 0
readonly _BDW_LIB_CPU=1

# Detecta modelo, núcleos e arquitetura da CPU.
cpu_detectar() {
  local arquivo="${BDW_MOCK_CPUINFO:-/proc/cpuinfo}"
  local modelo=""

  if [[ -r "$arquivo" ]]; then
    modelo="$(awk -F': ' '/^model name/ {print $2; exit}' "$arquivo")"
    # ARM e outros usam campos diferentes de "model name".
    [[ -z "$modelo" ]] && modelo="$(awk -F': ' '/^Model/ {print $2; exit}' "$arquivo")"
  fi

  export BDW_CPU_MODELO="${modelo:-Desconhecido}"
  export BDW_CPU_NUCLEOS="${BDW_MOCK_NUCLEOS:-$(nproc 2>/dev/null || echo 1)}"
  BDW_CPU_ARQ="$(uname -m)"
  export BDW_CPU_ARQ

  log_debug "CPU: $BDW_CPU_MODELO ($BDW_CPU_NUCLEOS núcleos, $BDW_CPU_ARQ)"
}
