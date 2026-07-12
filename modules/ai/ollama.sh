#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: ollama — Modelos de IA locais (LLMs)
# ============================================================================

BDW_MODULE_ID="ollama"
BDW_MODULE_NOME="Ollama"
BDW_MODULE_DESC="Execução local de LLMs (com download opcional de modelos)"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="sistema"
BDW_MODULE_TIMEOUT=5400

# Modelos oferecidos na TUI (curados para uma workstation de dev).
_OLLAMA_MODELOS=(
  "llama3.2:3b"
  "qwen2.5-coder:7b"
  "deepseek-r1:8b"
  "gemma3:4b"
)

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe ollama
}

module_instalar() {
  # Instalador oficial: detecta GPU (NVIDIA/AMD) e configura o serviço.
  spin_executar "Instalando Ollama (instalador oficial)" \
    net_executar_script_remoto "https://ollama.com/install.sh"
}

module_configurar() {
  if [[ "${BDW_GPU_FABRICANTE:-}" == "nvidia" ]]; then
    log_info "GPU NVIDIA detectada — o Ollama usará aceleração se o driver estiver ativo."
  fi

  # Download de modelos: só na TUI (downloads de vários GB não entram em CI).
  if [[ "$BDW_NAO_INTERATIVO" == "1" ]]; then
    log_info "Modo não-interativo: pulei o download de modelos (rode: ollama pull <modelo>)."
    return 0
  fi

  local escolhidos=()
  mapfile -t escolhidos < <(ui_multiselecionar \
    "Quais modelos baixar agora? (vários GB cada)" "" "${_OLLAMA_MODELOS[@]}")

  local modelo
  for modelo in "${escolhidos[@]}"; do
    [[ -z "$modelo" ]] && continue
    spin_executar "Baixando modelo $modelo" ollama pull "$modelo" ||
      log_aviso "Falha ao baixar $modelo — tente depois: ollama pull $modelo"
  done
}

module_reverter() {
  # Reversão conforme documentação oficial do Ollama.
  if [[ "${BDW_TEM_SYSTEMD:-0}" == "1" ]]; then
    como_root systemctl disable --now ollama 2>/dev/null || true
    como_root rm -f /etc/systemd/system/ollama.service
  fi
  como_root rm -f /usr/local/bin/ollama /usr/bin/ollama
  log_aviso "Modelos baixados em /usr/share/ollama foram MANTIDOS. Remova manualmente se desejar."
}
