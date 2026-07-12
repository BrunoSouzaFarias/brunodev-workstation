#!/usr/bin/env bash
# ============================================================================
# uninstall.sh — Desinstalador do BrunoDev Workstation
#
# Remove módulos instalados pela ferramenta, usando o manifesto de estado
# como fonte de verdade e o verbo module_reverter de cada módulo.
#
# Uso:
#   ./uninstall.sh          # seleção interativa dos módulos a remover
#   ./uninstall.sh --sim    # remove TODOS os módulos do manifesto (CI)
# ============================================================================

set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"

[[ "${1:-}" == "--sim" || "${1:-}" == "-y" ]] && export BDW_NAO_INTERATIVO=1

main() {
  sistema_detectar_tudo
  log_iniciar uninstall
  ui_banner

  local instalados=()
  mapfile -t instalados < <(estado_listar)
  if ((${#instalados[@]} == 0)); then
    log_info "Nenhum módulo registrado no manifesto. Nada a remover."
    exit 0
  fi

  # Em modo não-interativo remove tudo; na TUI o usuário escolhe.
  local selecionados=()
  if [[ "$BDW_NAO_INTERATIVO" == "1" ]]; then
    selecionados=("${instalados[@]}")
  else
    mapfile -t selecionados < <(ui_multiselecionar \
      "Selecione os módulos a REMOVER" "" "${instalados[@]}")
    ((${#selecionados[@]})) || {
      log_info "Nada selecionado. Saindo."
      exit 0
    }
    ui_confirmar "Remover ${#selecionados[@]} módulo(s)? Esta ação desfaz instalações e configurações." || exit 0
  fi

  sudo_manter_vivo

  local id codigo removidos=0 falhas=()
  progresso_definir_total "${#selecionados[@]}"
  for id in "${selecionados[@]}"; do
    progresso_passo "Removendo: $(mod_rotulo "$id")"
    codigo=0
    mod_executar "$id" reverter || codigo=$?
    if ((codigo == 0)); then
      estado_remover "$id"
      ((removidos++)) || true
    else
      falhas+=("$id")
    fi
  done

  ui_titulo "Resumo da remoção"
  log_sucesso "$removidos módulo(s) removido(s)."
  ((${#falhas[@]})) && log_erro "Falhas: ${falhas[*]}"

  if [[ -z "$(estado_listar)" ]]; then
    ui_nota "Manifesto vazio. Para apagar também logs e estado: rm -rf $BDW_DIR_ESTADO $BDW_DIR_DADOS"
  fi
  ((${#falhas[@]} == 0))
}

main
