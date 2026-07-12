#!/usr/bin/env bash
# ============================================================================
# lib/network.sh — Conectividade e downloads
#
# Verificação de internet e downloads com retry, timeout e log.
# ============================================================================

[[ -n "${_BDW_LIB_NETWORK:-}" ]] && return 0
readonly _BDW_LIB_NETWORK=1

# Tentativas e timeout (segundos) padrão para downloads.
BDW_DOWNLOAD_TENTATIVAS="${BDW_DOWNLOAD_TENTATIVAS:-3}"
BDW_DOWNLOAD_TIMEOUT="${BDW_DOWNLOAD_TIMEOUT:-120}"

# Verifica conectividade com a internet (testa mais de um endpoint).
net_tem_internet() {
  local url
  for url in "https://github.com" "https://cloudflare.com"; do
    if curl -fsI --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

# Baixa uma URL para um destino, com retry e validação.
# Uso: net_baixar <url> <arquivo-destino>
net_baixar() {
  local url="$1" destino="$2"
  validar_url "$url" || {
    log_erro "URL inválida: $url"
    return 1
  }
  mkdir -p "$(dirname "$destino")"
  if curl -fSL --retry "$BDW_DOWNLOAD_TENTATIVAS" --retry-delay 2 \
    --connect-timeout 15 --max-time "$BDW_DOWNLOAD_TIMEOUT" \
    -o "$destino" "$url" 2>>"${BDW_ARQ_LOG:-/dev/null}"; then
    log_debug "Download concluído: $url → $destino"
    return 0
  fi
  log_erro "Falha ao baixar: $url"
  rm -f "$destino"
  return 1
}

# Descobre a tag da última release de um repositório GitHub sem usar a API
# (segue o redirect de /releases/latest, evitando limites de requisição).
# Uso: net_github_ultima_tag "charmbracelet/gum"
net_github_ultima_tag() {
  local repo="$1" url_final
  url_final="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
    --connect-timeout 10 --max-time 20 \
    "https://github.com/$repo/releases/latest" 2>/dev/null)" || return 1
  [[ "$url_final" == */tag/* ]] || return 1
  printf '%s' "${url_final##*/tag/}"
}

# Executa um script remoto de forma controlada: baixa primeiro, depois roda.
# Mais seguro e depurável que "curl | bash" direto.
#
# Executa pelo próprio shebang do script (não força bash): vários
# instaladores oficiais (uv, Starship, Ollama) usam "#!/bin/sh" e se
# recusam a rodar sob bash não-POSIX, detectando BASH_VERSION.
#
# Uso: net_executar_script_remoto <url> [args...]
net_executar_script_remoto() {
  local url="$1"
  shift
  local script_tmp
  script_tmp="$(mktemp --suffix=.sh)"
  net_baixar "$url" "$script_tmp" || return 1
  chmod +x "$script_tmp"
  local codigo=0
  executar_logado "$script_tmp" "$@" || codigo=$?
  rm -f "$script_tmp"
  return "$codigo"
}
