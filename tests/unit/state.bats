#!/usr/bin/env bats
# Testes de lib/state.sh (manifesto de instalação)

setup() {
  load ../helpers/carregar
  carregar_lib_isolada
}

@test "registrar e consultar módulo no manifesto" {
  ! estado_contem docker
  estado_registrar docker
  estado_contem docker
}

@test "registrar duas vezes não duplica a entrada" {
  estado_registrar docker
  estado_registrar docker
  [[ "$(estado_listar | grep -c '^docker$')" -eq 1 ]]
}

@test "remover módulo do manifesto" {
  estado_registrar docker
  estado_registrar git
  estado_remover docker
  ! estado_contem docker
  estado_contem git
}

@test "estado_listar retorna apenas os ids" {
  estado_registrar docker
  estado_registrar vscode
  local listagem
  listagem="$(estado_listar | sort | tr '\n' ' ')"
  [[ "$listagem" == "docker vscode " ]]
}

@test "manifesto vazio não quebra listagem nem remoção" {
  estado_remover inexistente
  [[ -z "$(estado_listar)" ]]
}
