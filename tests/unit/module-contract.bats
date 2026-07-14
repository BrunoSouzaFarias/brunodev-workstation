#!/usr/bin/env bats
# ============================================================================
# Teste de contrato: cada módulo deve exportar os 5 verbos obrigatórios
# ============================================================================

setup() {
  PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

@test "todos os módulos declaram os 5 verbos obrigatórios" {
  local falhas=()
  local verbos=(module_compativel module_verificar module_instalar module_configurar module_reverter)

  while IFS= read -r arquivo; do
    # Pula arquivos que começam com _ (helpers como _comum.sh)
    local base
    base="$(basename "$arquivo")"
    [[ "$base" == _* ]] && continue

    for verbo in "${verbos[@]}"; do
      if ! grep -qE "^${verbo}\(\)" "$arquivo"; then
        falhas+=("$arquivo: falta $verbo()")
      fi
    done
  done < <(find "$PROJECT_ROOT/modules" -name '*.sh' -type f)

  if ((${#falhas[@]})); then
    printf '%s\n' "${falhas[@]}"
    return 1
  fi
}

@test "todos os módulos declaram metadados BDW_MODULE_ID e BDW_MODULE_CATEGORIA" {
  local falhas=()

  while IFS= read -r arquivo; do
    local base
    base="$(basename "$arquivo")"
    [[ "$base" == _* ]] && continue

    for meta in BDW_MODULE_ID BDW_MODULE_CATEGORIA; do
      if ! grep -q "^${meta}=" "$arquivo"; then
        falhas+=("$arquivo: falta $meta")
      fi
    done
  done < <(find "$PROJECT_ROOT/modules" -name '*.sh' -type f)

  if ((${#falhas[@]})); then
    printf '%s\n' "${falhas[@]}"
    return 1
  fi
}