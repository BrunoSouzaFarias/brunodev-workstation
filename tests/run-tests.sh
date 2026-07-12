#!/usr/bin/env bash
# ============================================================================
# tests/run-tests.sh — Executor de testes do BrunoDev Workstation
#
# Uso:
#   ./tests/run-tests.sh               # testes unitários (bats)
#   ./tests/run-tests.sh --integracao  # E2E em container ubuntu:24.04
#
# O bats-core é baixado automaticamente para tests/.bats na primeira execução.
# ============================================================================

set -Eeuo pipefail

TESTES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(dirname "$TESTES_DIR")"
BATS_VERSAO="1.11.0"
BATS_BIN="$TESTES_DIR/.bats/bin/bats"

# Garante o bats-core disponível localmente (sem dependência global).
garantir_bats() {
  [[ -x "$BATS_BIN" ]] && return 0
  echo "→ Baixando bats-core v$BATS_VERSAO..."
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSAO}.tar.gz" |
    tar -xz -C "$tmp"
  mkdir -p "$TESTES_DIR/.bats"
  "$tmp/bats-core-$BATS_VERSAO/install.sh" "$TESTES_DIR/.bats" >/dev/null
  rm -rf "$tmp"
}

executar_unitarios() {
  garantir_bats
  echo "→ Executando testes unitários..."
  "$BATS_BIN" --print-output-on-failure "$TESTES_DIR/unit"
}

executar_integracao() {
  command -v docker >/dev/null || {
    echo "✖ Docker é necessário para os testes de integração." >&2
    exit 1
  }
  echo "→ Executando teste de integração em container ubuntu:24.04..."
  docker run --rm \
    -v "$RAIZ":/opt/brunodev-workstation:ro \
    -e DEBIAN_FRONTEND=noninteractive \
    ubuntu:24.04 \
    bash /opt/brunodev-workstation/tests/integration/instalacao.sh
}

case "${1:-}" in
  --integracao) executar_integracao ;;
  "") executar_unitarios ;;
  *)
    echo "Uso: $0 [--integracao]" >&2
    exit 1
    ;;
esac
