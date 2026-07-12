#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: java — JDK via SDKMAN
#
# O SDKMAN não é compatível com "set -u/-e"; os comandos sdk rodam em um
# bash separado, sem strict mode, com a saída registrada no log.
# ============================================================================

BDW_MODULE_ID="java"
BDW_MODULE_NOME="Java (SDKMAN)"
BDW_MODULE_DESC="JDK atual via SDKMAN, com troca de versões fácil"
BDW_MODULE_CATEGORIA="languages"
BDW_MODULE_DEPS="sistema"
BDW_MODULE_TIMEOUT=2700

module_compativel() {
  return 0
}

module_verificar() {
  [[ -d "$HOME/.sdkman/candidates/java/current" ]]
}

# Garante o SDKMAN instalado e em modo não-interativo.
_java_garantir_sdkman() {
  if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    rollback_registrar "rm -rf '$HOME/.sdkman'"
    spin_executar "Instalando SDKMAN" \
      net_executar_script_remoto "https://get.sdkman.io"
  fi
  # Respostas automáticas para uso em scripts.
  fs_adicionar_linha "$HOME/.sdkman/etc/config" "sdkman_auto_answer=true"
}

module_instalar() {
  _java_garantir_sdkman
  # shellcheck disable=SC2016  # expansão intencional no bash filho
  spin_executar "Instalando JDK (sdk install java)" \
    bash -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install java </dev/null'
}

module_configurar() {
  local versao
  versao="$(basename "$(readlink -f "$HOME/.sdkman/candidates/java/current" 2>/dev/null)" 2>/dev/null || true)"
  log_sucesso "Java ${versao:-} pronto via SDKMAN."
}

module_reverter() {
  rm -rf "$HOME/.sdkman/candidates/java"
  log_aviso "JDK removido. O SDKMAN foi mantido (pode servir a maven/gradle)."
}
