#!/usr/bin/env bash
# ============================================================================
# Exporta os módulos instalados atualmente (via manifesto) para um perfil customizado.
# ============================================================================

set -e

BDW_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." 2>/dev/null && pwd)"
source "$BDW_ROOT/lib/init.sh"
sistema_detectar_tudo

if [[ ! -f "$BDW_ARQ_MANIFESTO" ]]; then
  log_erro "Manifesto não encontrado. Instale algo primeiro."
  exit 1
fi

DEST="$1"
if [[ -z "$DEST" ]]; then
  DEST="$BDW_ROOT/configs/profiles/meu_perfil.list"
fi

{
  echo "# Perfil exportado em $(date)"
  estado_listar
} > "$DEST"

log_sucesso "Perfil exportado para: $DEST"
ui_nota "Uso: ./install.sh --profile $(basename "$DEST" .list)"