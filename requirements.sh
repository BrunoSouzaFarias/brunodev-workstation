#!/usr/bin/env bash
# ============================================================================
# requirements.sh — Verificação de requisitos do sistema
#
# Valida se a máquina atende aos requisitos mínimos antes de qualquer
# instalação. Pode ser executado sozinho (./requirements.sh) para um
# diagnóstico rápido, ou sourceado pelo install.sh.
# ============================================================================

[[ -n "${_BDW_REQUIREMENTS:-}" ]] && return 0 2>/dev/null
_BDW_REQUIREMENTS=1

# Espaço mínimo em disco (GB) para uma instalação completa.
readonly BDW_DISCO_MINIMO_GB=10
# RAM recomendada (GB) — abaixo disso apenas alerta.
readonly BDW_RAM_RECOMENDADA_GB=4

# Verifica todos os requisitos. Encerra com mensagem amigável se algum
# requisito obrigatório não for atendido.
requisitos_verificar() {
  log_info "Verificando requisitos do sistema..."

  # Bash moderno (associativos e namerefs exigem >= 4).
  if ((BASH_VERSINFO[0] < 4)); then
    log_fatal "Bash 4 ou superior é necessário (encontrado: $BASH_VERSION)."
  fi

  # Nunca rodar como root — exceto em containers (CI), onde root é o padrão.
  if eh_root && [[ "${BDW_CONTAINER:-0}" != "1" ]]; then
    log_fatal "Não execute como root. Rode como usuário normal; o sudo será solicitado quando necessário."
  fi

  # Distribuição suportada.
  if ! distro_suportada; then
    log_erro "Distribuição não suportada: $BDW_DISTRO_NOME"
    log_erro "Suportadas nesta versão: $(distro_lista_suportadas)"
    log_info "Fedora, Pop!_OS e Debian chegam na v2.0 — acompanhe o ROADMAP."
    exit 1
  fi
  log_sucesso "Distribuição suportada: $BDW_DISTRO_NOME"

  # Conectividade.
  if ! net_tem_internet; then
    log_fatal "Sem conexão com a internet. Verifique sua rede e tente novamente."
  fi
  log_sucesso "Conexão com a internet OK"

  # Espaço em disco.
  if ((BDW_DISCO_LIVRE_GB < BDW_DISCO_MINIMO_GB)); then
    log_fatal "Espaço insuficiente: ${BDW_DISCO_LIVRE_GB}GB livres (mínimo: ${BDW_DISCO_MINIMO_GB}GB)."
  fi
  log_sucesso "Espaço em disco OK (${BDW_DISCO_LIVRE_GB}GB livres)"

  # Avisos não-bloqueantes.
  if ((BDW_RAM_GB < BDW_RAM_RECOMENDADA_GB)); then
    log_aviso "RAM abaixo do recomendado (${BDW_RAM_GB}GB < ${BDW_RAM_RECOMENDADA_GB}GB): módulos de IA local podem sofrer."
  fi
  if [[ "$BDW_SECURE_BOOT" == "ativado" && "$BDW_GPU_FABRICANTE" == "nvidia" ]]; then
    log_aviso "Secure Boot ativado com GPU NVIDIA: a assinatura do driver pode exigir passos manuais (MOK)."
  fi
}

# Execução direta: diagnóstico independente.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -Eeuo pipefail
  source "$(dirname "${BASH_SOURCE[0]}")/lib/init.sh"
  sistema_detectar_tudo
  requisitos_verificar
  log_sucesso "Todos os requisitos atendidos."
fi
