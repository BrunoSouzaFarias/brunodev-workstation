#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: ssh-hardening — Endurecimento do servidor SSH
#
# Aplica um drop-in em /etc/ssh/sshd_config.d/ (não edita o sshd_config
# principal). PasswordAuthentication NÃO é alterado para evitar lockout;
# desative manualmente após validar o acesso por chave.
# ============================================================================

BDW_MODULE_ID="ssh-hardening"
BDW_MODULE_NOME="SSH Hardening"
BDW_MODULE_DESC="Endurece o servidor SSH (root off, limites de auth, timeouts)"
BDW_MODULE_CATEGORIA="security"
BDW_MODULE_DEPS=""

_SSHD_DROPIN="/etc/ssh/sshd_config.d/99-brunodev-hardening.conf"

module_compativel() {
  return 0
}

module_verificar() {
  [[ -f "$_SSHD_DROPIN" ]]
}

module_instalar() {
  # O drop-in só tem efeito com o servidor instalado; não instalamos o
  # openssh-server automaticamente para não ampliar a superfície de ataque.
  pkg_existe openssh-server ||
    log_aviso "openssh-server não está instalado; o drop-in ficará pronto para quando estiver."
}

module_configurar() {
  fs_escrever_root "$_SSHD_DROPIN" <"$BDW_ROOT/configs/security/ssh-hardening.conf"

  # Valida a configuração antes de recarregar o serviço.
  if comando_existe sshd || [[ -x /usr/sbin/sshd ]]; then
    como_root /usr/sbin/sshd -t 2>>"${BDW_ARQ_LOG:-/dev/null}" ||
      log_fatal "Configuração SSH inválida — revertendo (drop-in não aplicado)."
  fi
  if [[ "${BDW_TEM_SYSTEMD:-0}" == "1" ]] && pkg_existe openssh-server; then
    executar_logado como_root systemctl reload ssh || true
  fi
  log_sucesso "Hardening SSH aplicado em $_SSHD_DROPIN"
  ui_nota "PasswordAuthentication não foi alterado. Após validar acesso por chave, desative-o manualmente."
}

module_reverter() {
  como_root rm -f "$_SSHD_DROPIN"
  if [[ "${BDW_TEM_SYSTEMD:-0}" == "1" ]] && pkg_existe openssh-server; then
    como_root systemctl reload ssh 2>/dev/null || true
  fi
}
