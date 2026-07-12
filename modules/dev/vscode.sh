#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: vscode — Visual Studio Code + extensões e configurações
# ============================================================================

BDW_MODULE_ID="vscode"
BDW_MODULE_NOME="VS Code"
BDW_MODULE_DESC="Editor com extensões (Copilot, Claude Code, Docker...) e settings prontos"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS=""
BDW_MODULE_TIMEOUT=2700

_VSCODE_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
_VSCODE_FLAG="$BDW_DIR_CONFIG/vscode-configurado"

module_compativel() {
  # Editor gráfico: sem sessão gráfica (servidores/containers) não faz sentido.
  [[ "${BDW_TEM_GUI:-0}" == "1" ]]
}

module_verificar() {
  comando_existe code && [[ -f "$_VSCODE_FLAG" ]]
}

module_instalar() {
  rollback_registrar "pkg_remover_repo_apt vscode"
  pkg_adicionar_repo_apt vscode \
    "https://packages.microsoft.com/keys/microsoft.asc" \
    "deb [arch=$(arquitetura_release) signed-by=/etc/apt/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main"
  pkg_instalar code
}

module_configurar() {
  # Configurações do usuário (com backup das existentes).
  fs_instalar_config "$BDW_ROOT/configs/vscode/settings.json" "$_VSCODE_USER_DIR/settings.json"
  fs_instalar_config "$BDW_ROOT/configs/vscode/keybindings.json" "$_VSCODE_USER_DIR/keybindings.json"

  local snippet
  for snippet in "$BDW_ROOT/configs/vscode/snippets"/*.json; do
    [[ -f "$snippet" ]] && fs_instalar_config "$snippet" "$_VSCODE_USER_DIR/snippets/$(basename "$snippet")"
  done

  # Extensões (idempotente: o code ignora as já instaladas).
  local extensao instaladas
  instaladas="$(code --list-extensions 2>/dev/null || true)"
  while IFS= read -r extensao; do
    [[ -z "$extensao" || "$extensao" == \#* ]] && continue
    if grep -qix "$extensao" <<<"$instaladas"; then
      log_debug "Extensão já instalada: $extensao"
      continue
    fi
    spin_executar "Extensão: $extensao" code --install-extension "$extensao" --force ||
      log_aviso "Não foi possível instalar a extensão $extensao (continuando)."
  done <"$BDW_ROOT/configs/vscode/extensions.list"

  fs_garantir_dir "$BDW_DIR_CONFIG"
  touch "$_VSCODE_FLAG"
}

module_reverter() {
  pkg_remover code || true
  pkg_remover_repo_apt vscode
  rm -f "$_VSCODE_FLAG"
  log_aviso "Configurações de usuário do VS Code mantidas (backups .bak-* disponíveis)."
}
