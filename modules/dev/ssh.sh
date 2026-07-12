#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: ssh — Cliente SSH, chave ed25519 e configuração do cliente
# ============================================================================

BDW_MODULE_ID="ssh"
BDW_MODULE_NOME="SSH"
BDW_MODULE_DESC="Chave ed25519, agente e configuração do cliente SSH"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS=""

_SSH_CHAVE="$HOME/.ssh/id_ed25519"
_SSH_CONFIG="$HOME/.ssh/config"
_SSH_MARCADOR="# >>> brunodev-workstation >>>"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe ssh &&
    [[ -f "$_SSH_CHAVE" ]] &&
    grep -q "$_SSH_MARCADOR" "$_SSH_CONFIG" 2>/dev/null
}

module_instalar() {
  pkg_instalar openssh-client
}

module_configurar() {
  fs_garantir_dir "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  # Gera a chave apenas se não existir — nunca sobrescreve chaves do usuário.
  if [[ ! -f "$_SSH_CHAVE" ]]; then
    local email
    email="$(git config --global user.email 2>/dev/null || true)"
    email="$(ui_entrada "E-mail para identificar a chave SSH" "${email:-$(usuario_alvo)@$(hostname)}")"
    spin_executar "Gerando chave SSH ed25519" \
      ssh-keygen -t ed25519 -C "$email" -f "$_SSH_CHAVE" -N ""
  else
    log_info "Chave SSH já existe — mantida."
  fi

  # Bloco de configuração gerenciado (idempotente via marcador).
  if ! grep -q "$_SSH_MARCADOR" "$_SSH_CONFIG" 2>/dev/null; then
    fs_backup_arquivo "$_SSH_CONFIG" >/dev/null
    cat >>"$_SSH_CONFIG" <<BLOCO
$_SSH_MARCADOR
Host *
  AddKeysToAgent yes
  ServerAliveInterval 60
  ServerAliveCountMax 3
  IdentityFile $_SSH_CHAVE
# <<< brunodev-workstation <<<
BLOCO
  fi
  chmod 600 "$_SSH_CONFIG"

  log_sucesso "SSH configurado. Sua chave pública:"
  cat "${_SSH_CHAVE}.pub" >&2 || true
  ui_nota "Adicione a chave ao GitHub: https://github.com/settings/keys (ou: gh ssh-key add)"
}

module_reverter() {
  # Remove apenas o bloco gerenciado. Chaves NUNCA são apagadas.
  if [[ -f "$_SSH_CONFIG" ]]; then
    sed -i '/# >>> brunodev-workstation >>>/,/# <<< brunodev-workstation <<</d' "$_SSH_CONFIG"
  fi
  log_aviso "Bloco de configuração removido. Chaves SSH foram mantidas por segurança."
}
