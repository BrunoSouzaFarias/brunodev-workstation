#!/usr/bin/env bash
# ============================================================================
# lib/spinner.sh — Indicador de atividade para operações longas
#
# spin_executar roda um comando em segundo plano exibindo um spinner
# animado. A saída do comando vai para o arquivo de log da sessão.
# Em modo não-interativo (CI/pipe) o spinner é substituído por logs simples.
# ============================================================================

[[ -n "${_BDW_LIB_SPINNER:-}" ]] && return 0
readonly _BDW_LIB_SPINNER=1

_BDW_SPINNER_QUADROS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

# Executa um comando exibindo spinner e mensagem.
# Uso: spin_executar "Instalando Docker" apt-get install -y docker-ce
# Retorna o código de saída do comando.
spin_executar() {
  local mensagem="$1"
  shift

  # Sem TTY ou em modo não-interativo: executa direto, sem animação.
  if [[ ! -t 1 || "${BDW_NAO_INTERATIVO:-0}" == "1" ]]; then
    log_info "$mensagem..."
    executar_logado "$@"
    return $?
  fi

  local arq_status
  arq_status="$(mktemp)"

  # Comando em segundo plano; código de saída gravado em arquivo temporário.
  (
    executar_logado "$@"
    echo $? >"$arq_status"
  ) &
  local pid=$!

  # Animação em primeiro plano enquanto o comando roda.
  local i=0
  tput civis 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null; do
    local quadro="${_BDW_SPINNER_QUADROS:i%${#_BDW_SPINNER_QUADROS}:1}"
    printf '\r%b%s%b %s ' "$BDW_COR_CIANO" "$quadro" "$BDW_COR_RESET" "$mensagem"
    ((i++)) || true
    sleep 0.1
  done
  wait "$pid" 2>/dev/null || true
  tput cnorm 2>/dev/null || true

  local codigo
  codigo="$(cat "$arq_status" 2>/dev/null || echo 1)"
  rm -f "$arq_status"

  # Limpa a linha do spinner e registra o resultado.
  printf '\r\033[K'
  if [[ "$codigo" -eq 0 ]]; then
    log_sucesso "$mensagem"
  else
    log_erro "$mensagem (código $codigo)"
  fi
  return "$codigo"
}
