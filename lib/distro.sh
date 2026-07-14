#!/usr/bin/env bash
# ============================================================================
# lib/distro.sh — Detecção da distribuição Linux
#
# Preenche as variáveis BDW_DISTRO_* a partir de /etc/os-release.
# Em testes, o arquivo pode ser substituído via BDW_MOCK_OS_RELEASE.
# ============================================================================

[[ -n "${_BDW_LIB_DISTRO:-}" ]] && return 0
readonly _BDW_LIB_DISTRO=1

# Distros suportadas na v1.0 (formato "id:versão-mínima").
readonly BDW_DISTROS_SUPORTADAS=(
  "ubuntu:24.04"
  "debian:12"
  "pop:22.04"
  "fedora:39"
  "arch:rolling"
  "endeavouros:rolling"
)

# Mapeia o par ID/ID_LIKE do os-release para uma família de pacotes.
# Saída: debian | fedora | arch | suse | desconhecida
distro_familia_de() {
  local id="$1" id_like="$2"
  case "$id" in
    ubuntu | debian | pop | linuxmint | neon) echo "debian" && return ;;
    fedora | ultramarine | nobara) echo "fedora" && return ;;
    arch | endeavouros | cachyos | manjaro) echo "arch" && return ;;
    opensuse* | sles) echo "suse" && return ;;
  esac
  case " $id_like " in
    *" debian "* | *" ubuntu "*) echo "debian" ;;
    *" fedora "* | *" rhel "*) echo "fedora" ;;
    *" arch "*) echo "arch" ;;
    *" suse "*) echo "suse" ;;
    *) echo "desconhecida" ;;
  esac
}

# Detecta a distribuição e exporta BDW_DISTRO_{ID,NOME,VERSAO,CODINOME,FAMILIA}.
distro_detectar() {
  local arquivo="${BDW_MOCK_OS_RELEASE:-/etc/os-release}"
  if [[ ! -r "$arquivo" ]]; then
    log_erro "Não foi possível ler $arquivo para detectar a distribuição."
    return 1
  fi

  # Variáveis locais capturam as atribuições feitas pelo source do os-release.
  local ID="" NAME="" VERSION_ID="" VERSION_CODENAME="" ID_LIKE="" PRETTY_NAME=""
  # shellcheck disable=SC1090
  source "$arquivo"

  export BDW_DISTRO_ID="${ID:-desconhecida}"
  export BDW_DISTRO_NOME="${PRETTY_NAME:-${NAME:-Desconhecida}}"
  export BDW_DISTRO_VERSAO="${VERSION_ID:-0}"
  export BDW_DISTRO_CODINOME="${VERSION_CODENAME:-}"
  BDW_DISTRO_FAMILIA="$(distro_familia_de "$BDW_DISTRO_ID" "${ID_LIKE:-}")"
  export BDW_DISTRO_FAMILIA

  log_debug "Distro: $BDW_DISTRO_NOME (id=$BDW_DISTRO_ID, família=$BDW_DISTRO_FAMILIA)"
}

# Verifica se a distribuição detectada é suportada pela versão atual.
distro_suportada() {
  local entrada id versao_minima
  for entrada in "${BDW_DISTROS_SUPORTADAS[@]}"; do
    id="${entrada%%:*}"
    versao_minima="${entrada##*:}"
    if [[ "$BDW_DISTRO_ID" == "$id" ]]; then
      # "rolling" sempre passa na checagem de versão.
      if [[ "$versao_minima" == "rolling" ]] || versao_maior_igual "$BDW_DISTRO_VERSAO" "$versao_minima"; then
        return 0
      fi
    fi
  done
  return 1
}

# Lista amigável das distros suportadas (para mensagens de erro).
distro_lista_suportadas() {
  local entrada saida=()
  for entrada in "${BDW_DISTROS_SUPORTADAS[@]}"; do
    saida+=("${entrada%%:*} ${entrada##*:}+")
  done
  printf '%s' "${saida[*]}"
}
