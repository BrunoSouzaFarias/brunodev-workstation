#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: sistema — Atualização do sistema e pacotes essenciais
# ============================================================================

BDW_MODULE_ID="sistema"
BDW_MODULE_NOME="Sistema Base"
BDW_MODULE_DESC="Atualiza o sistema e instala utilitários essenciais de build e CLI"
BDW_MODULE_CATEGORIA="system"
BDW_MODULE_DEPS=""
BDW_MODULE_TIMEOUT=2700

# Utilitários essenciais para desenvolvimento e para os demais módulos.
_SISTEMA_PACOTES=(
  build-essential ca-certificates curl wget gnupg lsb-release
  unzip zip tar jq htop tree nano ripgrep fd-find bat file
)

module_compativel() {
  return 0
}

module_verificar() {
  local pacote
  for pacote in "${_SISTEMA_PACOTES[@]}"; do
    pkg_existe "$pacote" || return 1
  done
}

module_instalar() {
  pkg_atualizar_indice
  spin_executar "Atualizando pacotes do sistema" \
    como_root env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  pkg_instalar "${_SISTEMA_PACOTES[@]}"
}

module_configurar() {
  return 0
}

module_reverter() {
  # Pacotes base são compartilhados por todo o sistema; removê-los poderia
  # quebrar programas do usuário. A reversão é intencionalmente conservadora.
  log_aviso "Pacotes essenciais do sistema são mantidos por segurança."
}
