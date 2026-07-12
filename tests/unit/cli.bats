#!/usr/bin/env bats
# Testes da interface de linha de comando do install.sh

setup() {
  load ../helpers/carregar
}

@test "install.sh --versao imprime a versão" {
  run bash "$BDW_REPO_REAL/install.sh" --versao
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "install.sh --ajuda documenta as opções principais" {
  run bash "$BDW_REPO_REAL/install.sh" --ajuda
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--perfil"* ]]
  [[ "$output" == *"--modulos"* ]]
  [[ "$output" == *"--sim"* ]]
}

@test "install.sh --perfis lista os perfis disponíveis" {
  run bash "$BDW_REPO_REAL/install.sh" --perfis
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"backend"* ]]
  [[ "$output" == *"ai-engineer"* ]]
  [[ "$output" == *"completo"* ]]
}

@test "install.sh --listar exibe o catálogo por categoria" {
  run bash "$BDW_REPO_REAL/install.sh" --listar
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"docker"* ]]
  [[ "$output" == *"claude-code"* ]]
  [[ "$output" == *"Bancos de Dados"* ]]
}

@test "install.sh rejeita opção desconhecida" {
  run bash "$BDW_REPO_REAL/install.sh" --nao-existe
  [[ "$status" -ne 0 ]]
}

@test "todos os módulos declaram os verbos obrigatórios" {
  local arquivo verbo
  for arquivo in "$BDW_REPO_REAL"/modules/*/*.sh; do
    [[ "$(basename "$arquivo")" == _* ]] && continue
    for verbo in module_compativel module_verificar module_instalar module_configurar module_reverter; do
      grep -q "^${verbo}()" "$arquivo" ||
        {
          echo "faltando $verbo em $arquivo"
          return 1
        }
    done
  done
}
