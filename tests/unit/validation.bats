#!/usr/bin/env bats
# Testes de lib/validation.sh

setup() {
  load ../helpers/carregar
  carregar_lib_isolada
}

@test "validar_email aceita endereços válidos" {
  validar_email "dev@exemplo.com"
  validar_email "nome.sobrenome+tag@sub.dominio.com.br"
}

@test "validar_email rejeita endereços inválidos" {
  ! validar_email "sem-arroba.com"
  ! validar_email "a@b"
  ! validar_email ""
}

@test "validar_url aceita http e https" {
  validar_url "https://github.com/user/repo"
  validar_url "http://localhost:8080/caminho"
}

@test "validar_url rejeita outros esquemas" {
  ! validar_url "ftp://servidor.com"
  ! validar_url "github.com"
}

@test "validar_id_modulo aceita ids no padrão kebab-case" {
  validar_id_modulo "docker"
  validar_id_modulo "docker-compose"
  validar_id_modulo "gemini-cli"
}

@test "validar_id_modulo rejeita maiúsculas, espaços e underscores" {
  ! validar_id_modulo "Docker"
  ! validar_id_modulo "meu modulo"
  ! validar_id_modulo "meu_modulo"
  ! validar_id_modulo "-inicio"
}

@test "validar_inteiro distingue números de texto" {
  validar_inteiro "42"
  ! validar_inteiro "4.2"
  ! validar_inteiro "abc"
}

@test "validar_nao_vazio e validar_caminho_absoluto" {
  validar_nao_vazio "x"
  ! validar_nao_vazio "   "
  validar_caminho_absoluto "/opt/coisa"
  ! validar_caminho_absoluto "relativo/coisa"
}
