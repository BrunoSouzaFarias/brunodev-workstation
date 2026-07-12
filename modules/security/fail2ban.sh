#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: fail2ban — Bloqueio automático de tentativas de invasão SSH
# ============================================================================

BDW_MODULE_ID="fail2ban"
BDW_MODULE_NOME="Fail2ban"
BDW_MODULE_DESC="Bane IPs após tentativas repetidas de login SSH"
BDW_MODULE_CATEGORIA="security"
BDW_MODULE_DEPS=""

module_compativel() {
  # O serviço depende de systemd (não disponível em containers/CI).
  [[ "${BDW_TEM_SYSTEMD:-0}" == "1" ]]
}

module_verificar() {
  pkg_existe fail2ban && [[ -f /etc/fail2ban/jail.local ]]
}

module_instalar() {
  pkg_instalar fail2ban
}

module_configurar() {
  fs_escrever_root /etc/fail2ban/jail.local <"$BDW_ROOT/configs/security/jail.local"
  executar_logado como_root systemctl enable --now fail2ban
  executar_logado como_root systemctl restart fail2ban
  log_sucesso "Fail2ban ativo protegendo o SSH."
}

module_reverter() {
  como_root systemctl disable --now fail2ban 2>/dev/null || true
  como_root rm -f /etc/fail2ban/jail.local
  pkg_remover fail2ban || true
}
