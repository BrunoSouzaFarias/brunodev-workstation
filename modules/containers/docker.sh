#!/usr/bin/env bash
# shellcheck disable=SC2034  # metadados BDW_MODULE_* são lidos pelo runtime via indireção
# ============================================================================
# Módulo: docker — Docker Engine via repositório oficial
# ============================================================================

BDW_MODULE_ID="docker"
BDW_MODULE_NOME="Docker Engine"
BDW_MODULE_DESC="Docker Engine + Buildx via repositório oficial, com grupo e daemon.json"
BDW_MODULE_CATEGORIA="containers"
BDW_MODULE_DEPS="sistema"
BDW_MODULE_TIMEOUT=2700

module_compativel() {
  return 0
}

module_verificar() {
  comando_existe docker && pkg_existe docker-ce
}

module_instalar() {
  # Remove versões antigas/conflitantes empacotadas pela distro.
  local conflito
  for conflito in docker.io docker-doc docker-compose podman-docker containerd runc; do
    pkg_existe "$conflito" && pkg_remover "$conflito"
  done

  rollback_registrar "pkg_remover_repo_apt docker"
  pkg_adicionar_repo_apt docker \
    "https://download.docker.com/linux/ubuntu/gpg" \
    "deb [arch=$(arquitetura_release) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $BDW_DISTRO_CODINOME stable"
  pkg_instalar docker-ce docker-ce-cli containerd.io docker-buildx-plugin
}

module_configurar() {
  # daemon.json com rotação de logs (evita disco cheio em uso prolongado).
  fs_escrever_root /etc/docker/daemon.json <"$BDW_ROOT/configs/docker/daemon.json"

  # Usuário no grupo docker (dispensa sudo para o CLI).
  local usuario="${SUDO_USER:-$USER}"
  if ! id -nG "$usuario" | grep -qw docker; then
    como_root groupadd -f docker
    como_root usermod -aG docker "$usuario"
    ui_nota "Grupo 'docker' aplicado. Abra uma nova sessão (ou rode: newgrp docker)."
  fi

  # Serviço só é gerenciável com systemd (não em containers/CI).
  if [[ "${BDW_TEM_SYSTEMD:-0}" == "1" ]]; then
    executar_logado como_root systemctl enable --now docker
    log_sucesso "Serviço docker habilitado."
  else
    log_aviso "Sem systemd nesta máquina — pulei a ativação do serviço."
  fi
}

module_reverter() {
  pkg_remover docker-ce docker-ce-cli containerd.io docker-buildx-plugin || true
  pkg_remover_repo_apt docker
  log_aviso "Imagens e volumes em /var/lib/docker foram MANTIDOS. Remova manualmente se desejar."
}
