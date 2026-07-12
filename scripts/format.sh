#!/usr/bin/env bash
# ============================================================================
# scripts/format.sh — Formata todo o código shell versionado (dev-only)
#
# Uso: ./scripts/format.sh   (requer shfmt no PATH)
# ============================================================================

set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

mapfile -t arquivos_sh < <(git ls-files '*.sh')
mapfile -t arquivos_bats < <(git ls-files '*.bats')

shfmt -i 2 -ci -w "${arquivos_sh[@]}"
((${#arquivos_bats[@]})) && shfmt -ln bats -i 2 -ci -w "${arquivos_bats[@]}"

echo "✔ Formatação aplicada"
