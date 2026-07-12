#!/usr/bin/env bash
# ============================================================================
# Helper comum dos testes: carrega a lib com diretórios de estado isolados.
# ============================================================================

# Raiz real do repositório (tests/helpers → raiz).
BDW_REPO_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export BDW_REPO_REAL

# Carrega a lib apontando estado/config/logs para um diretório isolado.
# Uso: carregar_lib_isolada [raiz-alternativa]
carregar_lib_isolada() {
  local raiz="${1:-$BDW_REPO_REAL}"
  export BDW_ROOT="$raiz"
  export BDW_DIR_DADOS="$BATS_TEST_TMPDIR/dados"
  export BDW_DIR_ESTADO="$BATS_TEST_TMPDIR/estado"
  export BDW_DIR_CONFIG="$BATS_TEST_TMPDIR/config"
  export BDW_DIR_LOGS="$BATS_TEST_TMPDIR/logs"
  export BDW_ARQ_MANIFESTO="$BATS_TEST_TMPDIR/estado/manifesto"
  export BDW_NAO_INTERATIVO=1
  # shellcheck disable=SC1091
  source "$raiz/lib/init.sh"
}

# Cria uma raiz falsa com a lib real (symlink) e modules/ vazio,
# para testar o runtime de módulos com fixtures controladas.
criar_raiz_fake() {
  local raiz="$BATS_TEST_TMPDIR/raiz"
  mkdir -p "$raiz/modules/system" "$raiz/modules/dev"
  ln -s "$BDW_REPO_REAL/lib" "$raiz/lib"
  ln -s "$BDW_REPO_REAL/assets" "$raiz/assets"
  printf '%s' "$raiz"
}
