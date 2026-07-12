#!/usr/bin/env bash
# ============================================================================
# scripts/lint.sh — Lint de todo o código do repositório (dev-only)
#
# Roda shellcheck e shfmt (modo diff) apenas nos arquivos versionados.
# Uso: ./scripts/lint.sh   (requer shellcheck e shfmt no PATH)
# ============================================================================

set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Todos os arquivos shell versionados (por extensão ou shebang conhecido).
mapfile -t arquivos_sh < <(git ls-files '*.sh' 'configs/backup/backup.conf')
mapfile -t arquivos_bats < <(git ls-files '*.bats')

echo "→ shellcheck em ${#arquivos_sh[@]} arquivos..."
shellcheck -x "${arquivos_sh[@]}"

echo "→ shfmt (diff) em ${#arquivos_sh[@]} arquivos..."
shfmt -i 2 -ci -d "${arquivos_sh[@]}"

if ((${#arquivos_bats[@]})); then
  echo "→ shfmt (diff) em ${#arquivos_bats[@]} arquivos bats..."
  shfmt -ln bats -i 2 -ci -d "${arquivos_bats[@]}"
fi

echo "✔ Lint OK"
