#!/usr/bin/env bash
# ============================================================================
# lib/utils.sh — Funções utilitárias genéricas do BrunoDev Workstation
# ============================================================================

[[ -n "${_BDW_LIB_UTILS:-}" ]] && return 0
readonly _BDW_LIB_UTILS=1

# Timeout padrão (em segundos) para operações de módulos.
BDW_TIMEOUT_PADRAO="${BDW_TIMEOUT_PADRAO:-1800}"

# Verifica se um comando está disponível no PATH.
comando_existe() {
  command -v "$1" >/dev/null 2>&1
}

# Falha com mensagem clara se algum dos comandos não existir.
# Uso: requer_comandos curl git
requer_comandos() {
  local cmd
  for cmd in "$@"; do
    comando_existe "$cmd" || log_fatal "Comando obrigatório não encontrado: $cmd"
  done
}

# Executa um comando com limite de tempo, registrando a saída no log.
# Uso: executar_com_timeout <segundos> <comando> [args...]
executar_com_timeout() {
  local segundos="$1"
  shift
  if [[ -n "${BDW_ARQ_LOG:-}" ]]; then
    timeout --foreground "$segundos" "$@" >>"$BDW_ARQ_LOG" 2>&1
  else
    timeout --foreground "$segundos" "$@"
  fi
}

# Executa um comando silenciosamente, direcionando a saída para o log.
executar_logado() {
  if [[ -n "${BDW_ARQ_LOG:-}" ]]; then
    "$@" >>"$BDW_ARQ_LOG" 2>&1
  else
    "$@" >/dev/null 2>&1
  fi
}

# Verifica se o processo atual roda como root.
eh_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]]
}

# Executa um comando com sudo quando necessário (sem sudo se já for root).
como_root() {
  if eh_root; then
    "$@"
  else
    sudo "$@"
  fi
}

# Remove espaços em branco no início e no fim de uma string.
aparar() {
  local texto="$*"
  texto="${texto#"${texto%%[![:space:]]*}"}"
  texto="${texto%"${texto##*[![:space:]]}"}"
  printf '%s' "$texto"
}

# Verifica se um elemento pertence a uma lista.
# Uso: contem_elemento "docker" "${modulos[@]}"
contem_elemento() {
  local alvo="$1" item
  shift
  for item in "$@"; do
    [[ "$item" == "$alvo" ]] && return 0
  done
  return 1
}

# Compara versões no formato semântico. Retorna 0 se v1 >= v2.
# Uso: versao_maior_igual "24.04" "22.04"
versao_maior_igual() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

# Gera uma senha aleatória segura (alfanumérica).
# Uso: gerar_senha [tamanho]
gerar_senha() {
  local tamanho="${1:-24}"
  LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$tamanho"
}

# Normaliza a arquitetura da máquina para o padrão usado em releases
# (amd64/arm64), comum em downloads de binários do GitHub.
arquitetura_release() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *) echo "desconhecida" ;;
  esac
}

# Mantém a credencial do sudo viva em segundo plano durante a instalação.
# O processo morre sozinho quando o script principal termina.
sudo_manter_vivo() {
  eh_root && return 0
  sudo -v || log_fatal "É necessário acesso sudo para continuar."
  (
    while kill -0 "$$" 2>/dev/null; do
      sudo -n true 2>/dev/null || true
      sleep 45
    done
  ) &
  disown
}
