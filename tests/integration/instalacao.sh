#!/usr/bin/env bash
# ============================================================================
# Teste de integração E2E — roda DENTRO de um container ubuntu:24.04
#
# Valida o ciclo completo: instalar → idempotência → desinstalar,
# usando o perfil "minimo" em modo não-interativo.
# Invocado por tests/run-tests.sh --integracao (monta o repo em /opt).
# ============================================================================

set -Eeuo pipefail

ORIGEM="/opt/brunodev-workstation"
TRABALHO="/root/bdw"

falha() {
  echo "✖ FALHA: $*" >&2
  exit 1
}

echo "=== [1/6] Preparando o container ==="
apt-get update -qq
apt-get install -y -qq curl git sudo ca-certificates >/dev/null

# Copia o repositório (montado como somente-leitura) para um diretório gravável.
cp -r "$ORIGEM" "$TRABALHO"
cd "$TRABALHO"

echo "=== [2/6] Instalação: perfil minimo (não-interativo) ==="
bash install.sh --perfil minimo --sim || falha "install.sh retornou erro"

echo "=== [3/6] Verificando artefatos instalados ==="
command -v git >/dev/null || falha "git não instalado"
command -v zsh >/dev/null || falha "zsh não instalado"
command -v starship >/dev/null || falha "starship não instalado"
command -v fastfetch >/dev/null || falha "fastfetch não instalado"
command -v pipx >/dev/null || falha "pipx não instalado"
command -v jq >/dev/null || falha "jq (módulo sistema) não instalado"
grep -q "brunodev-workstation" "$HOME/.zshrc" || falha ".zshrc não configurado"
git config --global --get include.path >/dev/null || falha "gitconfig-base não aplicado"

MANIFESTO="$HOME/.local/state/brunodev/manifesto"
[[ -f "$MANIFESTO" ]] || falha "manifesto não criado"
for modulo in sistema git shell python; do
  grep -q "^${modulo}|" "$MANIFESTO" || falha "módulo $modulo ausente do manifesto"
done

echo "=== [4/6] Idempotência: segunda execução deve pular tudo ==="
SAIDA="$(bash install.sh --perfil minimo --sim 2>&1)" || falha "segunda execução retornou erro"
grep -q "Instalados (0)" <<<"$SAIDA" || falha "segunda execução reinstalou módulos:
$SAIDA"

echo "=== [5/6] Desinstalação completa via manifesto ==="
bash uninstall.sh --sim || falha "uninstall.sh retornou erro"
[[ -z "$(cat "$MANIFESTO" 2>/dev/null)" ]] || falha "manifesto não ficou vazio após uninstall"

echo "=== [6/6] Diagnóstico standalone (requirements.sh) ==="
bash requirements.sh || falha "requirements.sh falhou em Ubuntu 24.04"

echo
echo "✔ Teste de integração E2E concluído com sucesso."
