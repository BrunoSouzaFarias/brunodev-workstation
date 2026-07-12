#!/usr/bin/env bash
# ============================================================================
# install.sh — Instalador do BrunoDev Workstation
#
# Transforma uma instalação limpa do Linux em uma workstation completa de
# desenvolvimento, DevOps e IA.
#
# Uso:
#   ./install.sh                      # modo interativo (TUI)
#   ./install.sh --perfil backend     # instala um perfil pronto
#   ./install.sh --modulos git,docker # instala módulos específicos
#   ./install.sh --perfil devops --sim  # não-interativo (CI/containers)
#
# Instalação remota:
#   bash <(curl -fsSL https://raw.githubusercontent.com/BrunoSouzaFarias/brunodev-workstation/main/install.sh)
# ============================================================================

set -Eeuo pipefail

# --- Modo remoto (curl | bash) ------------------------------------------------
# Se este script não está dentro de um clone do repositório, clona para o
# diretório de dados do usuário e re-executa a partir de lá.
_BDW_DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd || echo "")"
if [[ ! -f "$_BDW_DIR_SCRIPT/lib/init.sh" ]]; then
  BDW_REPO_REMOTO="https://github.com/BrunoSouzaFarias/brunodev-workstation"
  BDW_CLONE_DESTINO="${XDG_DATA_HOME:-$HOME/.local/share}/brunodev/workstation"
  echo "→ Baixando o BrunoDev Workstation para $BDW_CLONE_DESTINO..."
  command -v git >/dev/null 2>&1 || {
    echo "→ Instalando git..."
    sudo apt-get update -y && sudo apt-get install -y git
  }
  if [[ -d "$BDW_CLONE_DESTINO/.git" ]]; then
    git -C "$BDW_CLONE_DESTINO" pull --ff-only
  else
    mkdir -p "$(dirname "$BDW_CLONE_DESTINO")"
    git clone --depth 1 "$BDW_REPO_REMOTO" "$BDW_CLONE_DESTINO"
  fi
  exec bash "$BDW_CLONE_DESTINO/install.sh" "$@"
fi

source "$_BDW_DIR_SCRIPT/lib/init.sh"
source "$BDW_ROOT/bootstrap.sh"
source "$BDW_ROOT/requirements.sh"

# --- Ajuda e argumentos --------------------------------------------------------

exibir_ajuda() {
  cat <<AJUDA
$BDW_NOME v$BDW_VERSAO

Uso: ./install.sh [opções]

Opções:
  --perfil <nome>     Instala um perfil pronto (use --perfis para listar)
  --modulos <a,b,c>   Instala módulos específicos (separados por vírgula)
  --sim, -y           Modo não-interativo: assume "sim" para tudo
  --sem-tui           Desativa a interface rica (gum)
  --listar            Lista todos os módulos disponíveis e sai
  --perfis            Lista os perfis disponíveis e sai
  --debug             Ativa logs detalhados
  --versao            Exibe a versão e sai
  --ajuda, -h         Exibe esta ajuda

Exemplos:
  ./install.sh                          TUI interativa completa
  ./install.sh --perfil ai-engineer     Workstation de IA sem perguntas extras
  ./install.sh --modulos docker,vscode  Apenas Docker e VS Code
AJUDA
}

ARG_PERFIL=""
ARG_MODULOS=""
while (($#)); do
  case "$1" in
    --perfil)
      ARG_PERFIL="${2:?--perfil exige um nome}"
      shift
      ;;
    --modulos)
      ARG_MODULOS="${2:?--modulos exige uma lista}"
      shift
      ;;
    --sim | -y | --sem-tui) export BDW_NAO_INTERATIVO=1 ;;
    --listar) ARG_PERFIL="__listar__" ;;
    --perfis) ARG_PERFIL="__perfis__" ;;
    --debug) export BDW_LOG_NIVEL=debug ;;
    --versao)
      echo "$BDW_VERSAO"
      exit 0
      ;;
    --ajuda | -h)
      exibir_ajuda
      exit 0
      ;;
    *)
      echo "Opção desconhecida: $1 (use --ajuda)" >&2
      exit 1
      ;;
  esac
  shift
done

# --- Perfis ---------------------------------------------------------------------

# Lista os nomes de perfis disponíveis.
perfil_listar() {
  local arquivo
  for arquivo in "$BDW_ROOT/configs/profiles"/*.list; do
    [[ -f "$arquivo" ]] && basename "$arquivo" .list
  done
}

# Carrega os ids de módulos de um perfil (ignora comentários e vazios).
perfil_carregar() {
  local nome="$1" arquivo="$BDW_ROOT/configs/profiles/$1.list"
  [[ -f "$arquivo" ]] || log_fatal "Perfil não encontrado: $nome (use --perfis para listar)"
  grep -Ev '^[[:space:]]*(#|$)' "$arquivo" | tr -d '[:space:]' | grep . || true
}

# Lista módulos agrupados por categoria, marcando os já registrados.
modulos_exibir_catalogo() {
  local categoria id marca
  for categoria in "${BDW_CATEGORIAS_ORDEM[@]}"; do
    ui_titulo "$(categoria_nome "$categoria")"
    for id in $(mod_listar_ids); do
      [[ "$(mod_meta "$id" BDW_MODULE_CATEGORIA)" == "$categoria" ]] || continue
      marca=" "
      estado_contem "$id" && marca="✓"
      printf '  [%s] %-16s %s\n' "$marca" "$id" "$(mod_meta "$id" BDW_MODULE_DESC)"
    done
  done
}

# --- Seleção de módulos -----------------------------------------------------------

# Decide a lista de módulos a instalar conforme argumentos ou TUI.
# Resultado em BDW_SELECIONADOS (array global).
selecionar_modulos() {
  BDW_SELECIONADOS=()

  if [[ -n "$ARG_MODULOS" ]]; then
    IFS=',' read -r -a BDW_SELECIONADOS <<<"$ARG_MODULOS"
    return 0
  fi

  local base=()
  if [[ -n "$ARG_PERFIL" ]]; then
    mapfile -t base < <(perfil_carregar "$ARG_PERFIL")
  else
    # Escolha do perfil na TUI.
    local perfis=() escolha
    mapfile -t perfis < <(perfil_listar)
    escolha="$(ui_escolher "Escolha um perfil de instalação" "${perfis[@]}" "custom")"
    if [[ "$escolha" != "custom" ]]; then
      mapfile -t base < <(perfil_carregar "$escolha")
    fi
  fi

  # Em modo não-interativo o perfil é usado como veio, sem ajuste manual.
  if [[ "$BDW_NAO_INTERATIVO" == "1" ]]; then
    BDW_SELECIONADOS=("${base[@]}")
    ((${#BDW_SELECIONADOS[@]})) || log_fatal "Nenhum módulo selecionado. Use --perfil ou --modulos."
    return 0
  fi

  # Ajuste fino: multi-seleção com o perfil pré-marcado.
  local todos=() preselecao
  mapfile -t todos < <(mod_listar_ids)
  preselecao="$(
    IFS=,
    echo "${base[*]-}"
  )"
  mapfile -t BDW_SELECIONADOS < <(ui_multiselecionar \
    "Selecione os módulos a instalar" "$preselecao" "${todos[@]}")
  ((${#BDW_SELECIONADOS[@]})) || log_fatal "Nenhum módulo selecionado."
}

# Garante que todos os ids selecionados existem antes de prosseguir.
validar_selecao() {
  local id
  for id in "$@"; do
    validar_id_modulo "$id" || log_fatal "Id de módulo inválido: '$id'"
    mod_arquivo "$id" >/dev/null || log_fatal "Módulo inexistente: '$id' (use --listar para ver os disponíveis)"
  done
}

# --- Execução ---------------------------------------------------------------------

# Instala a lista de módulos (já ordenada por dependências) e resume o resultado.
executar_instalacao() {
  local lista=("$@")
  local instalados=() pulados=() incompativeis=() falhas=()
  local id codigo

  progresso_definir_total "${#lista[@]}"

  for id in "${lista[@]}"; do
    progresso_passo "$(mod_rotulo "$id")"
    codigo=0
    mod_executar "$id" instalar || codigo=$?

    case "$codigo" in
      0)
        estado_registrar "$id"
        instalados+=("$id")
        ;;
      2)
        log_info "Já instalado e atualizado — nada a fazer."
        pulados+=("$id")
        ;;
      3)
        log_aviso "Incompatível com este sistema — pulado."
        incompativeis+=("$id")
        ;;
      124)
        log_erro "Tempo esgotado na instalação de '$id'."
        falhas+=("$id")
        ;;
      *)
        falhas+=("$id")
        if ! ui_confirmar "O módulo '$id' falhou. Continuar com os demais?"; then
          log_aviso "Instalação interrompida pelo usuário."
          break
        fi
        ;;
    esac
  done

  # --- Resumo final ---
  ui_titulo "Resumo da instalação"
  printf '%b✔ Instalados (%d):%b %s\n' "$BDW_COR_VERDE" "${#instalados[@]}" "$BDW_COR_RESET" "${instalados[*]-nenhum}"
  printf '%b→ Já existiam (%d):%b %s\n' "$BDW_COR_AZUL" "${#pulados[@]}" "$BDW_COR_RESET" "${pulados[*]-nenhum}"
  ((${#incompativeis[@]})) &&
    printf '%b⚠ Incompatíveis (%d):%b %s\n' "$BDW_COR_AMARELO" "${#incompativeis[@]}" "$BDW_COR_RESET" "${incompativeis[*]}"
  ((${#falhas[@]})) &&
    printf '%b✖ Falhas (%d):%b %s\n' "$BDW_COR_VERMELHO" "${#falhas[@]}" "$BDW_COR_RESET" "${falhas[*]}"
  [[ -n "${BDW_ARQ_LOG:-}" ]] && printf '%bLog completo: %s%b\n' "$BDW_COR_FRACO" "$BDW_ARQ_LOG" "$BDW_COR_RESET"

  if ((${#instalados[@]})); then
    echo
    ui_nota "Abra um novo terminal (ou faça logout/login) para carregar PATH, grupos e shell atualizados."
  fi

  ((${#falhas[@]} == 0))
}

# --- Fluxo principal ---------------------------------------------------------------

main() {
  sistema_detectar_tudo
  log_iniciar install

  # Comandos informativos funcionam em qualquer sistema, antes dos requisitos.
  case "$ARG_PERFIL" in
    __listar__)
      modulos_exibir_catalogo
      exit 0
      ;;
    __perfis__)
      perfil_listar
      exit 0
      ;;
  esac

  ui_banner
  requisitos_verificar
  sudo_manter_vivo
  bootstrap_executar

  ui_titulo "Sistema detectado"
  ui_painel_sistema

  selecionar_modulos
  validar_selecao "${BDW_SELECIONADOS[@]}"

  # Expande dependências e ordena a execução.
  local ordenados=()
  mapfile -t ordenados < <(mod_resolver_dependencias "${BDW_SELECIONADOS[@]}")

  ui_titulo "Plano de instalação (${#ordenados[@]} módulos)"
  printf '  %s\n' "${ordenados[@]}"
  echo
  ui_confirmar "Iniciar a instalação?" || {
    log_info "Instalação cancelada."
    exit 0
  }

  executar_instalacao "${ordenados[@]}"
}

main
