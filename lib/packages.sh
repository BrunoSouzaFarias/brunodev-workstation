#!/usr/bin/env bash
# ============================================================================
# lib/packages.sh — Abstração de gerenciadores de pacotes
#
# As funções pkg_* despacham para o gerenciador da família da distro
# detectada (BDW_DISTRO_FAMILIA). Na v1.0 apenas a família debian (APT)
# está implementada; fedora/arch/suse retornam erro claro até a v2.0/v3.0.
# Flatpak e Snap são backends complementares, independentes da família.
# ============================================================================

[[ -n "${_BDW_LIB_PACKAGES:-}" ]] && return 0
readonly _BDW_LIB_PACKAGES=1

# Evita repetir "apt-get update" a cada módulo na mesma sessão.
_BDW_INDICE_ATUALIZADO=0

# Falha padrão para famílias ainda não implementadas.
_pkg_nao_suportado() {
  log_erro "Gerenciador de pacotes da família '$BDW_DISTRO_FAMILIA' ainda não é suportado (previsto para v2.0/v3.0)."
  return 1
}

# Atualiza o índice de pacotes (uma vez por sessão).
pkg_atualizar_indice() {
  [[ "$_BDW_INDICE_ATUALIZADO" == "1" ]] && return 0
  case "$BDW_DISTRO_FAMILIA" in
    debian)
      spin_executar "Atualizando índice de pacotes" \
        como_root env DEBIAN_FRONTEND=noninteractive apt-get update -y || return 1
      ;;
    *) _pkg_nao_suportado ;;
  esac
  _BDW_INDICE_ATUALIZADO=1
}

# Verifica se um pacote nativo está instalado.
pkg_existe() {
  case "$BDW_DISTRO_FAMILIA" in
    debian) dpkg -s "$1" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

# Instala um ou mais pacotes nativos (idempotente).
pkg_instalar() {
  local faltando=() pacote
  for pacote in "$@"; do
    pkg_existe "$pacote" || faltando+=("$pacote")
  done
  ((${#faltando[@]} == 0)) && return 0

  pkg_atualizar_indice || return 1
  case "$BDW_DISTRO_FAMILIA" in
    debian)
      spin_executar "Instalando pacotes: ${faltando[*]}" \
        como_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${faltando[@]}"
      ;;
    *) _pkg_nao_suportado ;;
  esac
}

# Remove um ou mais pacotes nativos.
pkg_remover() {
  case "$BDW_DISTRO_FAMILIA" in
    debian)
      spin_executar "Removendo pacotes: $*" \
        como_root env DEBIAN_FRONTEND=noninteractive apt-get remove -y "$@"
      ;;
    *) _pkg_nao_suportado ;;
  esac
}

# Instala um pacote .deb local (resolvendo dependências).
pkg_instalar_deb() {
  local arquivo="$1"
  spin_executar "Instalando $(basename "$arquivo")" \
    como_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$arquivo"
}

# Adiciona um repositório APT de terceiros com chave GPG dedicada.
# Uso: pkg_adicionar_repo_apt <nome> <url-da-chave> <linha-do-repositorio>
# Ex.: pkg_adicionar_repo_apt docker https://download.docker.com/linux/ubuntu/gpg \
#        "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://... noble stable"
pkg_adicionar_repo_apt() {
  local nome="$1" url_chave="$2" linha_repo="$3"
  local chave="/etc/apt/keyrings/${nome}.gpg"
  local lista="/etc/apt/sources.list.d/${nome}.list"

  como_root install -d -m 0755 /etc/apt/keyrings
  if [[ ! -f "$chave" ]]; then
    local tmp
    tmp="$(mktemp)"
    net_baixar "$url_chave" "$tmp" || return 1
    # Chaves podem vir em ASCII armor (precisam de dearmor) ou já binárias.
    if grep -q "BEGIN PGP PUBLIC KEY BLOCK" "$tmp" 2>/dev/null; then
      gpg --dearmor <"$tmp" | como_root tee "$chave" >/dev/null
    else
      como_root cp "$tmp" "$chave"
    fi
    como_root chmod a+r "$chave"
    rm -f "$tmp"
  fi

  echo "$linha_repo" | fs_escrever_root "$lista"
  _BDW_INDICE_ATUALIZADO=0 # força novo apt-get update na próxima instalação
  log_debug "Repositório APT adicionado: $nome"
}

# Remove um repositório APT adicionado por pkg_adicionar_repo_apt.
pkg_remover_repo_apt() {
  local nome="$1"
  como_root rm -f "/etc/apt/sources.list.d/${nome}.list" "/etc/apt/keyrings/${nome}.gpg"
}

# --- Flatpak ----------------------------------------------------------------

# Garante flatpak instalado e o remote flathub configurado.
flatpak_garantir() {
  comando_existe flatpak || pkg_instalar flatpak || return 1
  if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    spin_executar "Configurando Flathub" \
      como_root flatpak remote-add --if-not-exists flathub \
      https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
}

# Verifica se um app Flatpak está instalado.
flatpak_existe() {
  flatpak info "$1" >/dev/null 2>&1
}

# Instala um app do Flathub (idempotente).
flatpak_instalar() {
  local app="$1"
  flatpak_existe "$app" && return 0
  spin_executar "Instalando Flatpak: $app" \
    como_root flatpak install -y --noninteractive flathub "$app"
}

# --- Snap --------------------------------------------------------------------

# Verifica se um snap está instalado.
snap_existe() {
  snap list "$1" >/dev/null 2>&1
}

# Instala um snap (idempotente). Aceita flags extras (ex: --classic).
snap_instalar() {
  local pacote="$1"
  shift
  comando_existe snap || pkg_instalar snapd || return 1
  snap_existe "$pacote" && return 0
  spin_executar "Instalando Snap: $pacote" como_root snap install "$pacote" "$@"
}
