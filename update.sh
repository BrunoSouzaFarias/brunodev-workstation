#!/usr/bin/env bash
# ============================================================================
# update.sh — Atualizador do BrunoDev Workstation
#
# 1. Atualiza a própria ferramenta (git pull, quando for um clone).
# 2. Reprocessa os módulos registrados no manifesto — como todos os módulos
#    são idempotentes, isso atualiza o que mudou e pula o que está em dia.
#
# Uso: ./update.sh [--sim]
# ============================================================================

set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"

[[ "${1:-}" == "--sim" || "${1:-}" == "-y" ]] && export BDW_NAO_INTERATIVO=1

main() {
  sistema_detectar_tudo
  log_iniciar update
  ui_banner

  # Atualiza a ferramenta em si.
  if [[ -d "$BDW_ROOT/.git" ]] && comando_existe git; then
    log_info "Atualizando a ferramenta..."
    if git -C "$BDW_ROOT" pull --ff-only 2>>"${BDW_ARQ_LOG:-/dev/null}"; then
      log_sucesso "Ferramenta atualizada."
    else
      log_aviso "Não foi possível atualizar via git (alterações locais?). Prosseguindo."
    fi
  fi

  # Reprocessa os módulos instalados.
  local instalados=()
  mapfile -t instalados < <(estado_listar)
  if ((${#instalados[@]} == 0)); then
    log_info "Nenhum módulo registrado no manifesto. Nada a atualizar."
    exit 0
  fi

  ui_titulo "Módulos a atualizar (${#instalados[@]})"
  printf '  %s\n' "${instalados[@]}"
  ui_confirmar "Atualizar todos?" || exit 0

  sudo_manter_vivo

  local id codigo atualizados=0 em_dia=0 falhas=()
  progresso_definir_total "${#instalados[@]}"
  for id in "${instalados[@]}"; do
    progresso_passo "$(mod_rotulo "$id")"
    codigo=0
    mod_executar "$id" instalar || codigo=$?
    case "$codigo" in
      0)
        estado_registrar "$id"
        ((atualizados++)) || true
        ;;
      2 | 3) ((em_dia++)) || true ;;
      *) falhas+=("$id") ;;
    esac
  done

  ui_titulo "Resumo da atualização"
  log_sucesso "$atualizados atualizado(s), $em_dia já em dia."
  ((${#falhas[@]})) && log_erro "Falhas: ${falhas[*]}"
  ((${#falhas[@]} == 0))
}

main
