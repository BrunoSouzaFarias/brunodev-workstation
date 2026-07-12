#!/usr/bin/env bash
# ============================================================================
# lib/module.sh — Runtime de módulos do BrunoDev Workstation
#
# Um módulo é um arquivo modules/<categoria>/<id>.sh que define metadados
# (BDW_MODULE_*) e os verbos: module_compativel, module_verificar,
# module_instalar, module_configurar e module_reverter.
#
# Cada módulo roda em um PROCESSO FILHO dedicado (bash lib/module.sh ...):
#  - isola namespaces (módulos não colidem entre si)
#  - permite timeout real por módulo
#  - garante que rollback e trap de erro não vazem para o orquestrador
#
# Códigos de saída do runner:
#   0 = instalado com sucesso   2 = já instalado (pulado)
#   3 = incompatível com o sistema   124 = tempo esgotado   * = falha
# ============================================================================

if [[ -z "${_BDW_LIB_MODULE:-}" ]]; then
  readonly _BDW_LIB_MODULE=1

  readonly BDW_MOD_OK=0
  readonly BDW_MOD_JA_INSTALADO=2
  readonly BDW_MOD_INCOMPATIVEL=3

  # Ordem de exibição/execução das categorias.
  readonly BDW_CATEGORIAS_ORDEM=(system dev containers languages databases ai desktop security)

  # Nome amigável de uma categoria.
  categoria_nome() {
    case "$1" in
      system) echo "Sistema" ;;
      dev) echo "Desenvolvimento" ;;
      containers) echo "Containers" ;;
      languages) echo "Linguagens" ;;
      databases) echo "Bancos de Dados" ;;
      ai) echo "Inteligência Artificial" ;;
      desktop) echo "Desktop" ;;
      security) echo "Segurança" ;;
      *) echo "$1" ;;
    esac
  }

  # Caminho do arquivo de um módulo pelo id.
  mod_arquivo() {
    local id="$1" arquivo
    for arquivo in "$BDW_ROOT/modules"/*/"$id.sh"; do
      [[ -f "$arquivo" ]] && printf '%s' "$arquivo" && return 0
    done
    return 1
  }

  # Lista os ids de todos os módulos, na ordem das categorias.
  # Arquivos iniciados por "_" são helpers compartilhados, não módulos.
  mod_listar_ids() {
    local categoria arquivo
    for categoria in "${BDW_CATEGORIAS_ORDEM[@]}"; do
      for arquivo in "$BDW_ROOT/modules/$categoria"/*.sh; do
        [[ -f "$arquivo" && "$(basename "$arquivo")" != _* ]] && basename "$arquivo" .sh
      done
    done
  }

  # Lê um metadado de um módulo (com cache, sem poluir o shell atual).
  # Uso: mod_meta docker BDW_MODULE_NOME
  declare -A _BDW_META_CACHE
  mod_meta() {
    local id="$1" campo="$2" chave="$1.$2"
    if [[ -z "${_BDW_META_CACHE[$chave]+x}" ]]; then
      local arquivo
      arquivo="$(mod_arquivo "$id")" || log_fatal "Módulo não encontrado: $id"
      _BDW_META_CACHE[$chave]="$(
        # shellcheck disable=SC1090
        source "$arquivo"
        printf '%s' "${!campo:-}"
      )"
    fi
    printf '%s' "${_BDW_META_CACHE[$chave]}"
  }

  # Rótulo amigável de um módulo para menus: "id — Nome".
  mod_rotulo() {
    printf '%s — %s' "$1" "$(mod_meta "$1" BDW_MODULE_NOME)"
  }

  # --- Resolução de dependências (ordenação topológica) ---------------------
  _BDW_RESOLVIDOS=()
  declare -A _BDW_VISITADO

  _mod_visitar() {
    local id="$1"
    case "${_BDW_VISITADO[$id]:-}" in
      ok) return 0 ;;
      proc) log_fatal "Dependência circular envolvendo o módulo '$id'" ;;
    esac
    _BDW_VISITADO[$id]="proc"
    local dep
    for dep in $(mod_meta "$id" BDW_MODULE_DEPS); do
      _mod_visitar "$dep"
    done
    _BDW_VISITADO[$id]="ok"
    _BDW_RESOLVIDOS+=("$id")
  }

  # Expande uma lista de ids incluindo dependências, em ordem de execução.
  # Uso: mod_resolver_dependencias docker-compose node → docker docker-compose nvm node
  mod_resolver_dependencias() {
    _BDW_RESOLVIDOS=()
    _BDW_VISITADO=()
    local id
    for id in "$@"; do
      _mod_visitar "$id"
    done
    ((${#_BDW_RESOLVIDOS[@]})) && printf '%s\n' "${_BDW_RESOLVIDOS[@]}"
  }

  # Executa uma ação de um módulo em processo filho, com timeout.
  # Uso: mod_executar <id> [instalar|reverter]
  # Retorna os códigos documentados no cabeçalho.
  mod_executar() {
    local id="$1" acao="${2:-instalar}"
    local arquivo
    arquivo="$(mod_arquivo "$id")" || {
      log_erro "Módulo não encontrado: $id"
      return 1
    }
    local timeout_s
    timeout_s="$(mod_meta "$id" BDW_MODULE_TIMEOUT)"
    local codigo=0
    timeout --foreground "${timeout_s:-$BDW_TIMEOUT_PADRAO}" \
      bash "$BDW_ROOT/lib/module.sh" "$acao" "$arquivo" || codigo=$?
    return "$codigo"
  }
fi

# ============================================================================
# Modo runner: "bash lib/module.sh <ação> <arquivo-do-módulo>"
# Executado apenas quando este arquivo é invocado diretamente.
# ============================================================================

# --- Pilha de rollback (viva apenas no processo do runner) -------------------
_BDW_ROLLBACK_ACOES=()

# Registra uma ação de desfazer, executada em ordem reversa se algo falhar.
# Uso: rollback_registrar "como_root rm -rf /opt/coisa"
rollback_registrar() {
  _BDW_ROLLBACK_ACOES+=("$*")
}

_rollback_executar() {
  local i
  for ((i = ${#_BDW_ROLLBACK_ACOES[@]} - 1; i >= 0; i--)); do
    log_aviso "Rollback: ${_BDW_ROLLBACK_ACOES[i]}"
    eval "${_BDW_ROLLBACK_ACOES[i]}" || true
  done
}

_mod_trap_erro() {
  local codigo="$1"
  trap - ERR
  log_erro "Falha durante a execução do módulo (código $codigo)."
  _rollback_executar
  exit "$codigo"
}

_mod_runner() {
  local acao="$1" arquivo="$2"
  [[ -f "$arquivo" ]] || log_fatal "Arquivo de módulo inexistente: $arquivo"
  # shellcheck disable=SC1090
  source "$arquivo"

  trap '_mod_trap_erro $?' ERR

  case "$acao" in
    instalar)
      if ! module_compativel; then
        exit "$BDW_MOD_INCOMPATIVEL"
      fi
      if module_verificar; then
        exit "$BDW_MOD_JA_INSTALADO"
      fi
      module_instalar
      module_configurar
      exit "$BDW_MOD_OK"
      ;;
    reverter)
      module_reverter
      exit "$BDW_MOD_OK"
      ;;
    *)
      log_fatal "Ação desconhecida: $acao"
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -Eeuo pipefail
  source "$(dirname "${BASH_SOURCE[0]}")/init.sh"
  _mod_runner "$@"
fi
