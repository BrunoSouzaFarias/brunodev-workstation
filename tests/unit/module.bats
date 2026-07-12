#!/usr/bin/env bats
# Testes de lib/module.sh (runtime de módulos, com fixtures)

setup() {
  load ../helpers/carregar
  RAIZ_FAKE="$(criar_raiz_fake)"

  # Fixture: módulo base sem dependências.
  cat >"$RAIZ_FAKE/modules/system/alfa.sh" <<'EOF'
BDW_MODULE_ID="alfa"
BDW_MODULE_NOME="Alfa"
BDW_MODULE_DESC="módulo de teste"
BDW_MODULE_CATEGORIA="system"
BDW_MODULE_DEPS=""
module_compativel() { return 0; }
module_verificar() { [[ -f "$BDW_DIR_ESTADO/alfa-instalado" ]]; }
module_instalar() { mkdir -p "$BDW_DIR_ESTADO"; touch "$BDW_DIR_ESTADO/alfa-instalado"; }
module_configurar() { return 0; }
module_reverter() { rm -f "$BDW_DIR_ESTADO/alfa-instalado"; }
EOF

  # Fixture: módulo que depende do alfa.
  cat >"$RAIZ_FAKE/modules/dev/beta.sh" <<'EOF'
BDW_MODULE_ID="beta"
BDW_MODULE_NOME="Beta"
BDW_MODULE_DESC="depende do alfa"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS="alfa"
module_compativel() { return 0; }
module_verificar() { return 1; }
module_instalar() { return 0; }
module_configurar() { return 0; }
module_reverter() { return 0; }
EOF

  # Fixture: módulo incompatível.
  cat >"$RAIZ_FAKE/modules/dev/gama.sh" <<'EOF'
BDW_MODULE_ID="gama"
BDW_MODULE_NOME="Gama"
BDW_MODULE_DESC="sempre incompatível"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS=""
module_compativel() { return 1; }
module_verificar() { return 1; }
module_instalar() { return 0; }
module_configurar() { return 0; }
module_reverter() { return 0; }
EOF

  # Helper compartilhado não deve aparecer como módulo.
  echo '# helper' >"$RAIZ_FAKE/modules/dev/_helper.sh"

  carregar_lib_isolada "$RAIZ_FAKE"
}

@test "mod_listar_ids encontra módulos e ignora helpers _*" {
  local ids
  ids="$(mod_listar_ids | tr '\n' ' ')"
  [[ "$ids" == "alfa beta gama " ]]
}

@test "mod_meta lê metadados sem poluir o shell" {
  [[ "$(mod_meta beta BDW_MODULE_NOME)" == "Beta" ]]
  [[ "$(mod_meta beta BDW_MODULE_DEPS)" == "alfa" ]]
  [[ -z "${BDW_MODULE_NOME:-}" ]]
}

@test "mod_resolver_dependencias ordena dependências antes" {
  local ordem
  ordem="$(mod_resolver_dependencias beta | tr '\n' ' ')"
  [[ "$ordem" == "alfa beta " ]]
}

@test "mod_resolver_dependencias não duplica módulos" {
  local ordem
  ordem="$(mod_resolver_dependencias beta alfa beta | tr '\n' ' ')"
  [[ "$ordem" == "alfa beta " ]]
}

@test "mod_executar instala e retorna 0" {
  run mod_executar alfa instalar
  [[ "$status" -eq 0 ]]
}

@test "mod_executar retorna 2 quando já instalado (idempotência)" {
  mod_executar alfa instalar
  run mod_executar alfa instalar
  [[ "$status" -eq 2 ]]
}

@test "mod_executar retorna 3 para módulo incompatível" {
  run mod_executar gama instalar
  [[ "$status" -eq 3 ]]
}

@test "mod_executar reverter desfaz a instalação" {
  mod_executar alfa instalar
  run mod_executar alfa reverter
  [[ "$status" -eq 0 ]]
  run mod_executar alfa instalar
  [[ "$status" -eq 0 ]] # instala de novo pois foi revertido
}

@test "mod_arquivo falha para módulo inexistente" {
  ! mod_arquivo nao-existe
}
