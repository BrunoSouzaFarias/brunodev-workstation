## O que este PR faz

Descreva a mudança e por quê.

## Tipo de mudança

- [ ] Novo módulo
- [ ] Correção de bug
- [ ] Nova funcionalidade
- [ ] Refatoração
- [ ] Documentação
- [ ] Outro:

## Checklist

- [ ] `./scripts/lint.sh` passa sem erros (shellcheck + shfmt)
- [ ] `./tests/run-tests.sh` passa (testes unitários)
- [ ] Testado manualmente em Ubuntu 24.04 (ou container `ubuntu:24.04`)
- [ ] Módulos novos implementam os 5 verbos (`module_compativel`, `module_verificar`, `module_instalar`, `module_configurar`, `module_reverter`) e são idempotentes
- [ ] Documentação atualizada, se aplicável (README, docs/MODULOS.md, CHANGELOG)

## Como testar

Passos para validar esta mudança localmente.
