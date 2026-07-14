#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================================
# Módulo: gpg
# ============================================================================

BDW_MODULE_ID="gpg"
BDW_MODULE_NOME="GPG Setup"
BDW_MODULE_DESC="Instala GnuPG e configura pinentry para commit signing"
BDW_MODULE_CATEGORIA="security"
BDW_MODULE_DEPS="sistema"

module_compativel() { return 0; }

module_verificar() {
  comando_existe gpg && grep -q "pinentry" "$BDW_DIR_HOME/.gnupg/gpg-agent.conf" 2>/dev/null
}

module_instalar() {
  pkg_instalar gnupg2 pinentry-tty pinentry-gtk2
}

module_configurar() {
  local gnupg_dir="$BDW_DIR_HOME/.gnupg"
  fs_garantir_dir "$gnupg_dir" 0700

  local agent_conf="$gnupg_dir/gpg-agent.conf"
  
  if ! grep -q "pinentry-program" "$agent_conf" 2>/dev/null; then
    local pinentry_path
    pinentry_path="$(command -v pinentry-gtk-2 2>/dev/null || command -v pinentry-tty 2>/dev/null || echo '/usr/bin/pinentry')"
    echo "pinentry-program $pinentry_path" | fs_escrever "$agent_conf"
    echo "default-cache-ttl 34560000" | fs_escrever "$agent_conf" --append
    echo "max-cache-ttl 34560000" | fs_escrever "$agent_conf" --append
    fs_mudar_dono "$agent_conf" 0600
    
    executar_logado gpg-connect-agent reloadagent /bye >/dev/null 2>&1 || true
    ui_nota "GPG agent configurado com cache longo."
  fi
}

module_reverter() {
  rm -f "$BDW_DIR_HOME/.gnupg/gpg-agent.conf" || true
}