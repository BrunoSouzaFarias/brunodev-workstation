#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================================
# Módulo: hardware-tuning — Otimização de Performance
# ============================================================================

BDW_MODULE_ID="hardware-tuning"
BDW_MODULE_NOME="Hardware Auto-Tuning"
BDW_MODULE_DESC="Ajustes de energia, TLP para laptops e aceleração (CUDA/ROCm)"
BDW_MODULE_CATEGORIA="system"
BDW_MODULE_DEPS="sistema"

module_compativel() {
  [[ "${BDW_CONTAINER:-0}" == "0" && "$BDW_VM" == "nao" ]]
}

module_verificar() {
  if [[ "$BDW_CHASSI" == "laptop" ]]; then
    pkg_existe tlp || return 1
  fi
  # Simplificado: se laptop, tlp basta para 'instalado'. Desktop assume pronto.
  return 0
}

module_instalar() {
  if [[ "$BDW_CHASSI" == "laptop" ]]; then
    pkg_instalar tlp tlp-rdw
  fi
}

module_configurar() {
  if [[ "$BDW_CHASSI" == "laptop" && "$BDW_TEM_SYSTEMD" == "1" ]]; then
    ui_nota "Ativando otimizações de bateria (TLP)..."
    como_root systemctl enable --now tlp.service
  fi

  if [[ "$BDW_GPU_FABRICANTE" == "nvidia" ]]; then
    ui_nota "GPU NVIDIA detectada. Certifique-se de instalar drivers proprietários (ubuntu-drivers autoinstall)."
  elif [[ "$BDW_GPU_FABRICANTE" == "amd" ]]; then
    ui_nota "GPU AMD detectada. ROCm suportado nativamente pelo kernel AMDGPU."
  fi
}

module_reverter() {
  if [[ "$BDW_CHASSI" == "laptop" ]]; then
    como_root systemctl disable --now tlp.service 2>/dev/null || true
    pkg_remover tlp tlp-rdw || true
  fi
}