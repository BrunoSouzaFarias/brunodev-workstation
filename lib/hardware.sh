#!/usr/bin/env bash
# ============================================================================
# lib/hardware.sh — Detecção de hardware e ambiente de execução
#
# RAM, disco, tipo de armazenamento, Secure Boot, sessão gráfica, máquina
# virtual, container, systemd e tipo de chassi (laptop/desktop).
# ============================================================================

[[ -n "${_BDW_LIB_HARDWARE:-}" ]] && return 0
readonly _BDW_LIB_HARDWARE=1

# RAM total em GB (arredondado).
_hw_ram_gb() {
  local arquivo="${BDW_MOCK_MEMINFO:-/proc/meminfo}"
  awk '/^MemTotal/ {printf "%.0f", $2 / 1024 / 1024}' "$arquivo" 2>/dev/null || echo 0
}

# Espaço livre (GB) na partição do diretório home.
_hw_disco_livre_gb() {
  df -BG --output=avail "$HOME" 2>/dev/null | tail -n1 | tr -dc '0-9' || echo 0
}

# Tipo do disco principal: nvme | ssd | hdd | desconhecido.
_hw_disco_tipo() {
  local linha rota tran
  linha="$(lsblk -dno ROTA,TRAN 2>/dev/null | head -n1 || true)"
  [[ -z "$linha" ]] && echo "desconhecido" && return
  read -r rota tran <<<"$linha"
  if [[ "${tran:-}" == "nvme" ]]; then
    echo "nvme"
  elif [[ "$rota" == "0" ]]; then
    echo "ssd"
  else
    echo "hdd"
  fi
}

# Estado do Secure Boot: ativado | desativado | desconhecido.
_hw_secure_boot() {
  if comando_existe mokutil; then
    case "$(mokutil --sb-state 2>/dev/null || true)" in
      *enabled*) echo "ativado" && return ;;
      *disabled*) echo "desativado" && return ;;
    esac
  fi
  [[ ! -d /sys/firmware/efi ]] && echo "desativado (BIOS legado)" && return
  echo "desconhecido"
}

# Tipo de sessão gráfica: wayland | x11 | nenhuma.
_hw_sessao() {
  case "${XDG_SESSION_TYPE:-}" in
    wayland) echo "wayland" ;;
    x11) echo "x11" ;;
    *)
      [[ -n "${WAYLAND_DISPLAY:-}" ]] && echo "wayland" && return
      [[ -n "${DISPLAY:-}" ]] && echo "x11" && return
      echo "nenhuma"
      ;;
  esac
}

# Nome do hipervisor quando rodando em VM, ou "nao".
_hw_vm() {
  local virt
  if comando_existe systemd-detect-virt; then
    virt="$(systemd-detect-virt --vm 2>/dev/null || true)"
    [[ -n "$virt" && "$virt" != "none" ]] && echo "$virt" && return
  fi
  echo "nao"
}

# Detecta execução dentro de container (Docker/Podman/LXC).
_hw_container() {
  [[ -f /.dockerenv || -f /run/.containerenv ]] && echo 1 && return
  if comando_existe systemd-detect-virt; then
    local virt
    virt="$(systemd-detect-virt --container 2>/dev/null || true)"
    [[ -n "$virt" && "$virt" != "none" ]] && echo 1 && return
  fi
  echo 0
}

# Chassi da máquina: laptop | desktop.
_hw_chassi() {
  local tipo
  tipo="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0)"
  # Tipos DMI de portáteis: 8=Portable 9=Laptop 10=Notebook 14=Sub Notebook 31=Convertible
  case "$tipo" in
    8 | 9 | 10 | 14 | 31) echo "laptop" && return ;;
  esac
  # Fallback: presença de bateria.
  if compgen -G '/sys/class/power_supply/BAT*' >/dev/null 2>&1; then
    echo "laptop"
  else
    echo "desktop"
  fi
}

# Detecta todo o hardware/ambiente e exporta as variáveis BDW_*.
hardware_detectar() {
  BDW_RAM_GB="$(_hw_ram_gb)"
  BDW_DISCO_LIVRE_GB="$(_hw_disco_livre_gb)"
  BDW_DISCO_TIPO="$(_hw_disco_tipo)"
  BDW_SECURE_BOOT="$(_hw_secure_boot)"
  BDW_SESSAO="$(_hw_sessao)"
  BDW_VM="$(_hw_vm)"
  BDW_CONTAINER="$(_hw_container)"
  BDW_CHASSI="$(_hw_chassi)"
  BDW_TEM_SYSTEMD=0
  [[ -d /run/systemd/system ]] && BDW_TEM_SYSTEMD=1
  BDW_TEM_GUI=0
  [[ "$BDW_SESSAO" != "nenhuma" ]] && BDW_TEM_GUI=1

  export BDW_RAM_GB BDW_DISCO_LIVRE_GB BDW_DISCO_TIPO BDW_SECURE_BOOT \
    BDW_SESSAO BDW_VM BDW_CONTAINER BDW_CHASSI BDW_TEM_SYSTEMD BDW_TEM_GUI

  log_debug "Hardware: ${BDW_RAM_GB}GB RAM, ${BDW_DISCO_LIVRE_GB}GB livres ($BDW_DISCO_TIPO), sessão=$BDW_SESSAO, vm=$BDW_VM, container=$BDW_CONTAINER"
}

# Executa toda a detecção do sistema (distro + cpu + gpu + hardware).
sistema_detectar_tudo() {
  distro_detectar
  cpu_detectar
  gpu_detectar
  hardware_detectar
}

# Resumo textual do sistema detectado (uma informação por linha "Rótulo|Valor").
sistema_resumo() {
  cat <<RESUMO
Sistema|$BDW_DISTRO_NOME
CPU|$BDW_CPU_MODELO (${BDW_CPU_NUCLEOS} núcleos)
GPU|$BDW_GPU_MODELO
RAM|${BDW_RAM_GB}GB
Disco|${BDW_DISCO_LIVRE_GB}GB livres (${BDW_DISCO_TIPO})
Sessão|$BDW_SESSAO
Secure Boot|$BDW_SECURE_BOOT
Máquina|$BDW_CHASSI$([[ "$BDW_VM" != "nao" ]] && printf ' (VM: %s)' "$BDW_VM")
RESUMO
}
