#!/usr/bin/env bats
# Testes de lib/utils.sh

setup() {
  load ../helpers/carregar
  carregar_lib_isolada
}

@test "versao_maior_igual compara versões semânticas" {
  versao_maior_igual "24.04" "24.04"
  versao_maior_igual "24.10" "24.04"
  versao_maior_igual "25.04" "24.04"
  ! versao_maior_igual "22.04" "24.04"
  ! versao_maior_igual "9.9" "10.0"
}

@test "contem_elemento localiza itens em listas" {
  contem_elemento "b" "a" "b" "c"
  ! contem_elemento "z" "a" "b" "c"
  ! contem_elemento "a" # lista vazia
}

@test "aparar remove espaços das bordas" {
  [[ "$(aparar '  texto  ')" == "texto" ]]
  [[ "$(aparar $'\t com tab \t')" == "com tab" ]]
  [[ "$(aparar '')" == "" ]]
}

@test "gerar_senha respeita o tamanho e é alfanumérica" {
  local senha
  senha="$(gerar_senha 32)"
  [[ ${#senha} -eq 32 ]]
  [[ "$senha" =~ ^[A-Za-z0-9]+$ ]]
  # Duas senhas seguidas não devem coincidir.
  [[ "$(gerar_senha 32)" != "$senha" ]]
}

@test "comando_existe detecta comandos reais e inexistentes" {
  comando_existe bash
  ! comando_existe comando-que-nao-existe-xyz
}

@test "arquitetura_release normaliza uname -m" {
  local arq
  arq="$(arquitetura_release)"
  [[ "$arq" == "amd64" || "$arq" == "arm64" || "$arq" == "desconhecida" ]]
}
