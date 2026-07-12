#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: podman — Containers sem daemon (rootless)
# ============================================================================

BDW_MODULE_ID="podman"
BDW_MODULE_NOME="Podman"
BDW_MODULE_DESC="Engine de containers rootless e sem daemon (alternativa ao Docker)"
BDW_MODULE_CATEGORIA="containers"
BDW_MODULE_DEPS=""

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe podman
}

module_instalar() {
  pkg_instalar podman
}

module_configurar() {
  return 0
}

module_reverter() {
  pkg_remover podman || true
}
