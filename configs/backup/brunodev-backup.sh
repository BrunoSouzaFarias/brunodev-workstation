#!/usr/bin/env bash
# ============================================================================
# brunodev-backup — Backup pessoal com rotação
#
# Diretórios e destino configuráveis em ~/.config/brunodev/backup.conf
# Instalado pelo BrunoDev Workstation (módulo backup).
# ============================================================================

set -Eeuo pipefail

# Configuração padrão (sobrescrita pelo backup.conf, se existir).
BACKUP_DIRS=("$HOME/Documentos" "$HOME/.config" "$HOME/.ssh")
BACKUP_DESTINO="$HOME/Backups"
BACKUP_MANTER=5

CONF="${XDG_CONFIG_HOME:-$HOME/.config}/brunodev/backup.conf"
# shellcheck disable=SC1090
[[ -f "$CONF" ]] && source "$CONF"

mkdir -p "$BACKUP_DESTINO"
arquivo="$BACKUP_DESTINO/backup-$(hostname)-$(date '+%Y%m%d-%H%M%S').tar.gz"

# Considera apenas diretórios que realmente existem.
existentes=()
for dir in "${BACKUP_DIRS[@]}"; do
  [[ -e "$dir" ]] && existentes+=("$dir")
done

if ((${#existentes[@]} == 0)); then
  echo "Nenhum diretório para backup encontrado." >&2
  exit 1
fi

echo "→ Gerando $arquivo"
tar -czf "$arquivo" --ignore-failed-read "${existentes[@]}" 2>/dev/null || true
echo "✔ Backup criado: $(du -h "$arquivo" | cut -f1)"

# Rotação: mantém apenas os N mais recentes.
mapfile -t antigos < <(find "$BACKUP_DESTINO" -maxdepth 1 -name 'backup-*.tar.gz' -printf '%T@ %p\n' |
  sort -rn | tail -n +$((BACKUP_MANTER + 1)) | cut -d' ' -f2-)
for velho in "${antigos[@]}"; do
  echo "→ Removendo backup antigo: $velho"
  rm -f "$velho"
done
