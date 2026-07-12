#!/usr/bin/env bash
# ============================================================================
# lib/gpu.sh — Detecção de GPU
#
# Preenche BDW_GPU_{FABRICANTE,MODELO} a partir do lspci. Quando existe mais
# de uma GPU, prioriza a dedicada (NVIDIA > AMD > Intel).
# Em testes, a saída do lspci pode ser substituída via BDW_MOCK_LSPCI (arquivo).
# ============================================================================

[[ -n "${_BDW_LIB_GPU:-}" ]] && return 0
readonly _BDW_LIB_GPU=1

# Lista as linhas de dispositivos de vídeo do lspci.
_gpu_linhas() {
  if [[ -n "${BDW_MOCK_LSPCI:-}" ]]; then
    grep -Ei 'vga|3d|display' "$BDW_MOCK_LSPCI" 2>/dev/null || true
  elif comando_existe lspci; then
    lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true
  fi
}

# Detecta fabricante e modelo da GPU principal.
gpu_detectar() {
  local linhas linha fabricante="desconhecida" modelo="Desconhecida"
  linhas="$(_gpu_linhas)"

  # Prioridade: NVIDIA (dedicada) > AMD > Intel (integrada).
  local padrao
  for padrao in "nvidia:NVIDIA" "amd:AMD|ATI|Radeon" "intel:Intel"; do
    linha="$(grep -Ei "${padrao##*:}" <<<"$linhas" | head -n1 || true)"
    if [[ -n "$linha" ]]; then
      fabricante="${padrao%%:*}"
      # Extrai a descrição do dispositivo (após o tipo "VGA ...: ").
      modelo="$(aparar "${linha#*: }")"
      break
    fi
  done

  export BDW_GPU_FABRICANTE="$fabricante"
  export BDW_GPU_MODELO="$modelo"
  log_debug "GPU: $BDW_GPU_MODELO (fabricante=$BDW_GPU_FABRICANTE)"
}
