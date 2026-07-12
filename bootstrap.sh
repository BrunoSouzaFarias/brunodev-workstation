#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh — Pré-requisitos mínimos do BrunoDev Workstation
#
# Garante as ferramentas necessárias para o instalador funcionar:
# curl, git e gum (TUI). O gum é baixado das releases oficiais para
# ~/.local/share/brunodev/bin — sem adicionar repositórios de terceiros.
#
# Pode ser executado sozinho (./bootstrap.sh) ou sourceado pelo install.sh.
# ============================================================================

[[ -n "${_BDW_BOOTSTRAP:-}" ]] && return 0 2>/dev/null
_BDW_BOOTSTRAP=1

# Versão do gum fixada para downloads reprodutíveis.
readonly BDW_GUM_VERSAO="0.14.5"

# Instala o gum a partir da release oficial do GitHub.
_bootstrap_gum() {
  comando_existe gum && return 0

  local arq_arch
  case "$(uname -m)" in
    x86_64) arq_arch="x86_64" ;;
    aarch64 | arm64) arq_arch="arm64" ;;
    *)
      log_aviso "Arquitetura sem binário do gum; a interface usará o modo texto."
      return 0
      ;;
  esac

  local nome="gum_${BDW_GUM_VERSAO}_Linux_${arq_arch}"
  local url="https://github.com/charmbracelet/gum/releases/download/v${BDW_GUM_VERSAO}/${nome}.tar.gz"
  local tmp
  tmp="$(mktemp -d)"

  if net_baixar "$url" "$tmp/gum.tar.gz" &&
    tar -xzf "$tmp/gum.tar.gz" -C "$tmp" "$nome/gum"; then
    fs_garantir_dir "$BDW_DIR_DADOS/bin"
    install -m 0755 "$tmp/$nome/gum" "$BDW_DIR_DADOS/bin/gum"
    log_sucesso "gum v${BDW_GUM_VERSAO} instalado em $BDW_DIR_DADOS/bin"
  else
    log_aviso "Não foi possível baixar o gum; a interface usará o modo texto."
  fi
  rm -rf "$tmp"
}

# Garante curl, git e gum disponíveis.
bootstrap_executar() {
  log_info "Verificando pré-requisitos do instalador..."

  local basicos=()
  comando_existe curl || basicos+=(curl)
  comando_existe git || basicos+=(git)
  comando_existe gpg || basicos+=(gnupg)
  ((${#basicos[@]})) && pkg_instalar "${basicos[@]}"

  _bootstrap_gum
  log_sucesso "Pré-requisitos prontos."
}

# Execução direta: roda o bootstrap de forma independente.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -Eeuo pipefail
  source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"
  distro_detectar
  bootstrap_executar
fi
