#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: git — Git, Git LFS e configuração global
# ============================================================================

BDW_MODULE_ID="git"
BDW_MODULE_NOME="Git"
BDW_MODULE_DESC="Git + LFS com configuração global (identidade, aliases e padrões modernos)"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS=""

# Config base versionada no repositório, aplicada via include.path.
_GIT_CONFIG_BASE_DESTINO="$BDW_DIR_CONFIG/gitconfig-base"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe git &&
    [[ -f "$_GIT_CONFIG_BASE_DESTINO" ]] &&
    git config --global --get include.path >/dev/null 2>&1
}

module_instalar() {
  pkg_instalar git git-lfs
}

module_configurar() {
  # Identidade: usa a existente como padrão; pergunta apenas na TUI.
  local nome email
  nome="$(ui_entrada "Seu nome para commits do Git" "$(git config --global user.name 2>/dev/null || true)")"
  email="$(ui_entrada "Seu e-mail para commits do Git" "$(git config --global user.email 2>/dev/null || true)")"

  [[ -n "$nome" ]] && git config --global user.name "$nome"
  if [[ -n "$email" ]]; then
    validar_email "$email" || log_aviso "E-mail em formato incomum: $email"
    git config --global user.email "$email"
  fi

  # Padrões modernos ficam num arquivo versionável, incluído no global.
  fs_instalar_config "$BDW_ROOT/configs/git/gitconfig-base" "$_GIT_CONFIG_BASE_DESTINO"
  git config --global include.path "$_GIT_CONFIG_BASE_DESTINO"

  executar_logado git lfs install --skip-repo

  # --- Assinatura de commits (SSH) ---
  # ponytail: suporte GPG quando demanda surgir; SSH cobre 90% dos casos
  if ui_confirmar "Ativar assinatura de commits via SSH?"; then
    local chave_ssh=""
    # Tenta encontrar chave SSH existente
    for f in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub"; do
      [[ -f "$f" ]] && chave_ssh="$f" && break
    done
    if [[ -z "$chave_ssh" ]]; then
      log_aviso "Nenhuma chave SSH encontrada. Gere com: ssh-keygen -t ed25519"
    else
      git config --global gpg.format ssh
      git config --global user.signingkey "$chave_ssh"
      git config --global commit.gpgsign true
      git config --global tag.gpgsign true
      log_sucesso "Assinatura de commits ativada com: $chave_ssh"
    fi
  fi

  log_sucesso "Git configurado para: ${nome:-?} <${email:-?}>"
}

module_reverter() {
  # Remove apenas o que este módulo configurou; o pacote git permanece,
  # pois outros programas do usuário podem depender dele.
  git config --global --unset include.path 2>/dev/null || true
  rm -f "$_GIT_CONFIG_BASE_DESTINO"
  log_aviso "Configuração removida. O pacote git foi mantido por segurança."
}
