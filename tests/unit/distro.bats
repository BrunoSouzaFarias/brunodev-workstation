#!/usr/bin/env bats
# Testes de lib/distro.sh (com os-release mockado)

setup() {
  load ../helpers/carregar
  carregar_lib_isolada
}

criar_os_release() {
  local arquivo="$BATS_TEST_TMPDIR/os-release"
  cat >"$arquivo"
  export BDW_MOCK_OS_RELEASE="$arquivo"
}

@test "detecta Ubuntu 24.04 como suportado (família debian)" {
  criar_os_release <<'EOF'
ID=ubuntu
NAME="Ubuntu"
PRETTY_NAME="Ubuntu 24.04.1 LTS"
VERSION_ID="24.04"
VERSION_CODENAME=noble
EOF
  distro_detectar
  [[ "$BDW_DISTRO_ID" == "ubuntu" ]]
  [[ "$BDW_DISTRO_FAMILIA" == "debian" ]]
  [[ "$BDW_DISTRO_CODINOME" == "noble" ]]
  distro_suportada
}

@test "rejeita Ubuntu 22.04 (abaixo da versão mínima)" {
  criar_os_release <<'EOF'
ID=ubuntu
VERSION_ID="22.04"
PRETTY_NAME="Ubuntu 22.04 LTS"
EOF
  distro_detectar
  ! distro_suportada
}

@test "detecta Ultramarine como família fedora, não suportada na v1.0" {
  criar_os_release <<'EOF'
ID=ultramarine
NAME="Ultramarine Linux"
VERSION_ID="44"
ID_LIKE=fedora
PRETTY_NAME="Ultramarine Linux 44"
EOF
  distro_detectar
  [[ "$BDW_DISTRO_FAMILIA" == "fedora" ]]
  ! distro_suportada
}

@test "usa ID_LIKE quando o ID é desconhecido" {
  criar_os_release <<'EOF'
ID=distromisteriosa
ID_LIKE="ubuntu debian"
VERSION_ID="1.0"
EOF
  distro_detectar
  [[ "$BDW_DISTRO_FAMILIA" == "debian" ]]
}

@test "família desconhecida para distros sem parentesco" {
  criar_os_release <<'EOF'
ID=solus
VERSION_ID="4.5"
EOF
  distro_detectar
  [[ "$BDW_DISTRO_FAMILIA" == "desconhecida" ]]
}
