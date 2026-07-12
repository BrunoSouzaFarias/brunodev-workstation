#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: open-webui — Interface web para LLMs locais (container)
# ============================================================================

BDW_MODULE_ID="open-webui"
BDW_MODULE_NOME="Open WebUI"
BDW_MODULE_DESC="Interface web tipo ChatGPT para o Ollama (localhost:3000)"
BDW_MODULE_CATEGORIA="ai"
BDW_MODULE_DEPS="docker ollama"
BDW_MODULE_TIMEOUT=2700

module_compativel() {
  # Precisa do daemon Docker acessível (não disponível em containers/CI).
  como_root docker info >/dev/null 2>&1
}

module_verificar() {
  como_root docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "bdw-open-webui"
}

module_instalar() {
  rollback_registrar "como_root docker rm -f bdw-open-webui"
  spin_executar "Subindo container do Open WebUI" \
    como_root docker run -d \
    --name bdw-open-webui \
    --restart unless-stopped \
    -p 127.0.0.1:3000:8080 \
    --add-host host.docker.internal:host-gateway \
    -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
    -v bdw-open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:main
}

module_configurar() {
  ui_nota "Open WebUI disponível em http://localhost:3000"
}

module_reverter() {
  como_root docker rm -f bdw-open-webui >/dev/null 2>&1 || true
  log_aviso "Volume de dados bdw-open-webui foi MANTIDO."
}
