#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: backup — Backup automático de arquivos pessoais
#
# Instala o script brunodev-backup (tar.gz com rotação) e um timer
# systemd de usuário para execução semanal.
# ============================================================================

BDW_MODULE_ID="backup"
BDW_MODULE_NOME="Backup"
BDW_MODULE_DESC="Backup semanal de documentos e configurações com rotação"
BDW_MODULE_CATEGORIA="security"
BDW_MODULE_DEPS=""

_BACKUP_BIN="$HOME/.local/bin/brunodev-backup"
_BACKUP_UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

module_compativel() {
  return 0
}

module_verificar() {
  [[ -x "$_BACKUP_BIN" ]]
}

module_instalar() {
  fs_garantir_dir "$(dirname "$_BACKUP_BIN")"
  fs_instalar_config "$BDW_ROOT/configs/backup/brunodev-backup.sh" "$_BACKUP_BIN"
  chmod +x "$_BACKUP_BIN"
  fs_instalar_config "$BDW_ROOT/configs/backup/backup.conf" "$BDW_DIR_CONFIG/backup.conf"
}

module_configurar() {
  # Timer semanal via systemd de usuário (quando disponível).
  if [[ "${BDW_TEM_SYSTEMD:-0}" != "1" ]]; then
    log_aviso "Sem systemd — agende o backup manualmente (ex: cron) chamando $_BACKUP_BIN"
    return 0
  fi

  fs_garantir_dir "$_BACKUP_UNIT_DIR"
  cat >"$_BACKUP_UNIT_DIR/brunodev-backup.service" <<UNIT
[Unit]
Description=BrunoDev Workstation — backup de arquivos pessoais

[Service]
Type=oneshot
ExecStart=$_BACKUP_BIN
UNIT

  cat >"$_BACKUP_UNIT_DIR/brunodev-backup.timer" <<UNIT
[Unit]
Description=BrunoDev Workstation — backup semanal

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
UNIT

  executar_logado systemctl --user daemon-reload || true
  executar_logado systemctl --user enable --now brunodev-backup.timer ||
    log_aviso "Não foi possível ativar o timer (sessão sem D-Bus?). Ative depois: systemctl --user enable --now brunodev-backup.timer"
  log_sucesso "Backup semanal configurado (destino padrão: ~/Backups)."
}

module_reverter() {
  if [[ "${BDW_TEM_SYSTEMD:-0}" == "1" ]]; then
    systemctl --user disable --now brunodev-backup.timer 2>/dev/null || true
  fi
  rm -f "$_BACKUP_BIN" \
    "$_BACKUP_UNIT_DIR/brunodev-backup.service" \
    "$_BACKUP_UNIT_DIR/brunodev-backup.timer" \
    "$BDW_DIR_CONFIG/backup.conf"
  log_aviso "Backups existentes em ~/Backups foram MANTIDOS."
}
