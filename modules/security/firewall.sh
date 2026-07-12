#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: firewall — UFW com política segura para desktop
# ============================================================================

BDW_MODULE_ID="firewall"
BDW_MODULE_NOME="Firewall (UFW)"
BDW_MODULE_DESC="UFW ativo: bloqueia entradas, permite saídas e SSH"
BDW_MODULE_CATEGORIA="security"
BDW_MODULE_DEPS=""

module_compativel() {
  # UFW precisa de acesso real ao netfilter — indisponível em containers.
  [[ "${BDW_CONTAINER:-0}" == "0" ]]
}

module_verificar() {
  como_root ufw status 2>/dev/null | grep -q "Status: active"
}

module_instalar() {
  pkg_instalar ufw
}

module_configurar() {
  executar_logado como_root ufw default deny incoming
  executar_logado como_root ufw default allow outgoing
  # Mantém acesso SSH quando o servidor está presente (evita lockout remoto).
  if pkg_existe openssh-server; then
    executar_logado como_root ufw allow OpenSSH
  fi
  spin_executar "Ativando firewall UFW" como_root ufw --force enable
}

module_reverter() {
  como_root ufw --force disable >/dev/null 2>&1 || true
  log_aviso "UFW desativado. O pacote foi mantido (faz parte do Ubuntu)."
}
