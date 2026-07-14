#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================================
# Módulo: kubernetes
# ============================================================================

BDW_MODULE_ID="kubernetes"
BDW_MODULE_NOME="Kubernetes Dev (kubectl, k3d, helm)"
BDW_MODULE_DESC="Ferramentas para desenvolvimento cloud-native local"
BDW_MODULE_CATEGORIA="dev"
BDW_MODULE_DEPS="sistema,docker"

module_compativel() { return 0; }

module_verificar() {
  comando_existe kubectl && comando_existe helm && comando_existe k3d
}

module_instalar() {
  # kubectl
  if ! comando_existe kubectl; then
    local k_ver
    k_ver="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
    net_baixar "https://dl.k8s.io/release/${k_ver}/bin/linux/amd64/kubectl" /usr/local/bin/kubectl
    como_root chmod +x /usr/local/bin/kubectl
  fi

  # helm
  if ! comando_existe helm; then
    net_executar_script_remoto https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  fi

  # k3d
  if ! comando_existe k3d; then
    net_executar_script_remoto https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh
  fi
}

module_configurar() {
  if ! grep -q "kubectl completion" "$BDW_DIR_HOME/.zshrc" 2>/dev/null; then
    ui_nota "Autocomplete do kubectl já tratado via plugin do Zsh."
  fi
}

module_reverter() {
  como_root rm -f /usr/local/bin/kubectl /usr/local/bin/helm /usr/local/bin/k3d
}