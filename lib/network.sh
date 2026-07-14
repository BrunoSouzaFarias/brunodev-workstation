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
# Usa múltiplos métodos sequenciais para evitar falsos negativos (ex: SSL inspection).
net_tem_internet() {
  local url
  if command -v curl >/dev/null 2>&1; then
    for url in "https://github.com" "https://cloudflare.com" "http://clients3.google.com/generate_204"; do
      curl -fsI --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1 && return 0
    done
  fi

  if command -v wget >/dev/null 2>&1; then
    for url in "https://github.com" "https://cloudflare.com"; do
      wget -q --spider --timeout=10 "$url" >/dev/null 2>&1 && return 0
    done
  fi

  # Fallback: tenta bash TCP socket ou ping.
  timeout 5 bash -c '</dev/tcp/8.8.8.8/53' >/dev/null 2>&1 && return 0
  ping -c1 -W5 8.8.8.8 >/dev/null 2>&1 && return 0

  # ponytail: evita falso-negativo bloqueante; pacotes falharão naturalmente se não houver rede
  return 0
}

# Baixa uma URL para um destino, com retry e validação.
# Uso: net_baixar <url> <arquivo-destino> [sha256-esperado]
net_baixar() {
  local url="$1" destino="$2" checksum="${3:-}"
  validar_url "$url" || {
    log_erro "URL inválida: $url"
    return 1
  }
  mkdir -p "$(dirname "$destino")"
  if curl -fSL --retry "$BDW_DOWNLOAD_TENTATIVAS" --retry-delay 2 \
    --connect-timeout 15 --max-time "$BDW_DOWNLOAD_TIMEOUT" \
    -o "$destino" "$url" 2>>"${BDW_ARQ_LOG:-/dev/null}"; then
    
    if [[ -n "$checksum" ]]; then
      local checksum_real
      checksum_real="$(sha256sum "$destino" | awk '{print $1}')"
      if [[ "$checksum_real" != "$checksum" ]]; then
        log_erro "Checksum inválido para $destino: esperado $checksum, obtido $checksum_real"
        rm -f "$destino"
        return 1
      fi
    fi
    
    log_debug "Download concluído: $url → $destino"
    return 0
  fi
  log_erro "Falha ao baixar: $url"
  rm -f "$destino"
  return 1
  printf '%s' "${url_final##*/tag/}"
}

# Baixa múltiplas URLs em paralelo.
# Uso: net_baixar_paralelo <url1> <dest1> <url2> <dest2> ...
net_baixar_paralelo() {
  local pids=()
  local erro=0
  
  while (($# >= 2)); do
    local url="$1" dest="$2"
    shift 2
    net_baixar "$url" "$dest" &
    pids+=($!)
  done

  for pid in "${pids[@]}"; do
    wait "$pid" || erro=1
  done

  return "$erro"
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
