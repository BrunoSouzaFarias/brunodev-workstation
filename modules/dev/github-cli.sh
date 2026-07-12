#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: github-cli — GitHub CLI (gh) via repositório oficial
# ============================================================================

BDW_MODULE_ID="github-cli"
BDW_MODULE_NOME="GitHub CLI"
BDW_MODULE_DESC="Cliente oficial do GitHub (gh) para PRs, issues e autenticação"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS="git"

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe gh
}

module_instalar() {
  rollback_registrar "pkg_remover_repo_apt github-cli"
  pkg_adicionar_repo_apt github-cli \
    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
    "deb [arch=$(arquitetura_release) signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main"
  pkg_instalar gh
}

module_configurar() {
  if gh auth status >/dev/null 2>&1; then
    log_sucesso "GitHub CLI já autenticado."
    return 0
  fi
  ui_nota "Para autenticar no GitHub, rode depois: gh auth login"
}

module_reverter() {
  pkg_remover gh || true
  pkg_remover_repo_apt github-cli
}
