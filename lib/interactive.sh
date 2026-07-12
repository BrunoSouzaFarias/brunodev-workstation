#!/usr/bin/env bash
# ============================================================================
# lib/interactive.sh — Camada de interface TUI (gum)
#
# Todas as interações com o usuário passam por aqui. Quando o gum não está
# disponível ou BDW_NAO_INTERATIVO=1, cada função tem um fallback sensato
# (read/echo ou o valor padrão), permitindo rodar em CI e containers.
# ============================================================================

[[ -n "${_BDW_LIB_INTERACTIVE:-}" ]] && return 0
readonly _BDW_LIB_INTERACTIVE=1

# Verifica se a TUI rica está disponível nesta execução.
ui_tem_gum() {
  [[ "$BDW_NAO_INTERATIVO" == "0" ]] && comando_existe gum && [[ -t 0 && -t 1 ]]
}

# Exibe o banner do projeto.
ui_banner() {
  local banner="$BDW_ROOT/assets/banner.txt"
  echo
  if [[ -f "$banner" ]]; then
    printf '%b' "$BDW_COR_CIANO"
    cat "$banner"
    printf '%b' "$BDW_COR_RESET"
  else
    printf '%b%s%b\n' "$BDW_COR_NEGRITO" "$BDW_NOME" "$BDW_COR_RESET"
  fi
  printf '%bv%s — sua workstation Linux pronta em um comando%b\n\n' \
    "$BDW_COR_FRACO" "$BDW_VERSAO" "$BDW_COR_RESET"
}

# Título de seção.
ui_titulo() {
  if ui_tem_gum; then
    gum style --bold --foreground 6 --margin "1 0 0 0" "$1"
  else
    printf '\n%b%s%b\n' "$BDW_COR_NEGRITO$BDW_COR_CIANO" "$1" "$BDW_COR_RESET"
  fi
}

# Painel com o resumo do sistema detectado (dados de sistema_resumo).
ui_painel_sistema() {
  local conteudo rotulo valor
  conteudo=""
  while IFS='|' read -r rotulo valor; do
    conteudo+="$(printf '%-13s %s' "$rotulo:" "$valor")"$'\n'
  done < <(sistema_resumo)

  if ui_tem_gum; then
    gum style --border rounded --padding "0 2" --border-foreground 6 "$conteudo"
  else
    printf '%s\n' "───────────────────────────────────────────"
    printf '%s' "$conteudo"
    printf '%s\n' "───────────────────────────────────────────"
  fi
}

# Pergunta de confirmação (sim/não). Retorna 0 para sim.
# Em modo não-interativo, assume "sim".
ui_confirmar() {
  local pergunta="$1"
  [[ "$BDW_NAO_INTERATIVO" == "1" ]] && return 0
  if ui_tem_gum; then
    gum confirm --affirmative "Sim" --negative "Não" "$pergunta"
  else
    local resposta
    read -r -p "$pergunta [S/n] " resposta
    [[ -z "$resposta" || "$resposta" =~ ^[SsYy] ]]
  fi
}

# Campo de texto. Uso: ui_entrada <rótulo> [valor-padrão]
# Em modo não-interativo, retorna o valor padrão.
ui_entrada() {
  local rotulo="$1" padrao="${2:-}"
  if [[ "$BDW_NAO_INTERATIVO" == "1" ]]; then
    printf '%s' "$padrao"
    return 0
  fi
  if ui_tem_gum; then
    gum input --header "$rotulo" --value "$padrao" --placeholder "$rotulo"
  else
    local resposta
    read -r -p "$rotulo${padrao:+ [$padrao]}: " resposta
    printf '%s' "${resposta:-$padrao}"
  fi
}

# Escolha única entre opções (uma por argumento). Ecoa a escolhida.
# Em modo não-interativo, retorna a primeira.
ui_escolher() {
  local rotulo="$1"
  shift
  if [[ "$BDW_NAO_INTERATIVO" == "1" ]]; then
    printf '%s' "$1"
    return 0
  fi
  if ui_tem_gum; then
    gum choose --header "$rotulo" --height 15 "$@"
  else
    printf '%s\n' "$rotulo" >&2
    select opcao in "$@"; do
      [[ -n "$opcao" ]] && printf '%s' "$opcao" && return 0
    done
  fi
}

# Seleção múltipla. Uso: ui_multiselecionar <rótulo> <pré-selecionadas-CSV> <opções...>
# Ecoa as opções escolhidas (uma por linha).
# Em modo não-interativo, retorna as pré-selecionadas.
ui_multiselecionar() {
  local rotulo="$1" preselecao="$2"
  shift 2
  if [[ "$BDW_NAO_INTERATIVO" == "1" ]] || ! ui_tem_gum; then
    [[ -n "$preselecao" ]] && tr ',' '\n' <<<"$preselecao"
    return 0
  fi
  gum choose --no-limit --header "$rotulo (espaço marca, enter confirma)" \
    --height 20 ${preselecao:+--selected "$preselecao"} "$@"
}

# Aviso destacado para mensagens importantes ao final da instalação.
ui_nota() {
  if ui_tem_gum; then
    gum style --border rounded --padding "0 1" --border-foreground 3 "$*"
  else
    printf '%b! %s%b\n' "$BDW_COR_AMARELO" "$*" "$BDW_COR_RESET"
  fi
}
