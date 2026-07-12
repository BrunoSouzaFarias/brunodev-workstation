#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: fonts — Nerd Fonts para terminal e editor
# ============================================================================

BDW_MODULE_ID="fonts"
BDW_MODULE_NOME="Fontes"
BDW_MODULE_DESC="Nerd Fonts (JetBrainsMono e CascadiaCode) com ícones para dev"
BDW_MODULE_CATEGORIA="desktop"
BDW_MODULE_DEPS=""

_FONTS_LISTA=(JetBrainsMono CascadiaCode)
_FONTS_DIR="$HOME/.local/share/fonts"

module_compativel() {
  [[ "${BDW_TEM_GUI:-0}" == "1" ]]
}

module_verificar() {
  local fonte
  for fonte in "${_FONTS_LISTA[@]}"; do
    [[ -d "$_FONTS_DIR/$fonte" ]] || return 1
  done
}

module_instalar() {
  local fonte tmp
  for fonte in "${_FONTS_LISTA[@]}"; do
    [[ -d "$_FONTS_DIR/$fonte" ]] && continue
    tmp="$(mktemp --suffix=.tar.xz)"
    net_baixar "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${fonte}.tar.xz" "$tmp"
    rollback_registrar "rm -rf '$_FONTS_DIR/$fonte'"
    fs_garantir_dir "$_FONTS_DIR/$fonte"
    spin_executar "Instalando fonte $fonte" tar -xJf "$tmp" -C "$_FONTS_DIR/$fonte"
    rm -f "$tmp"
  done
}

module_configurar() {
  spin_executar "Atualizando cache de fontes" fc-cache -f
}

module_reverter() {
  local fonte
  for fonte in "${_FONTS_LISTA[@]}"; do
    rm -rf "${_FONTS_DIR:?}/$fonte"
  done
  executar_logado fc-cache -f || true
}
