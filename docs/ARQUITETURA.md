# Arquitetura

Este documento explica como o BrunoDev Workstation é construído por dentro e por quê.

## Visão geral

```text
install.sh  ─┐
update.sh    ├─ orquestradores (usam a lib, nunca implementam lógica de módulo)
uninstall.sh ─┘
      │
      ▼
   lib/init.sh  ── carregador único: resolve BDW_ROOT e faz source de toda a lib
      │
      ├── núcleo: colors, logger, spinner, progress, utils, validation
      ├── detecção: distro, cpu, gpu, hardware, network, filesystem
      └── runtime: packages, interactive (TUI), state (manifesto), module
                                                              │
                                                              ▼
                                              modules/<categoria>/<id>.sh
```

Nenhum script chama outro shell fora dessa hierarquia. Toda funcionalidade nova nasce como uma função em `lib/` (se for reutilizável) ou como um módulo em `modules/` (se for uma instalação específica).

## Princípios

- **Um módulo por processo filho.** `mod_executar` roda cada módulo em `bash lib/module.sh <ação> <arquivo>`, isolado do orquestrador. Isso permite timeout real por módulo, evita colisão de nomes de função entre módulos, e garante que um módulo mal comportado não corrompe o estado do instalador.
- **Idempotência é obrigatória, não opcional.** Todo módulo implementa `module_verificar`, chamado antes de instalar. Se retornar sucesso, o módulo é pulado. Rodar `install.sh` duas vezes nunca deve reinstalar nada.
- **Rollback em pilha.** Dentro de `module_instalar`, chamadas a `rollback_registrar "comando"` empilham ações de desfazer. Se qualquer comando falhar (via `trap ERR`), a pilha é executada em ordem reversa antes de propagar o erro.
- **Nunca curl-pipe direto.** `net_executar_script_remoto` sempre baixa o script para um arquivo temporário antes de executá-lo — nunca `curl | bash`. Isso torna os scripts de terceiros auditáveis e depuráveis a partir do log da sessão.
- **Tudo reversível tem backup.** `fs_instalar_config` e `fs_backup_arquivo` nunca sobrescrevem um arquivo do usuário sem antes copiá-lo para `<arquivo>.bak-<timestamp>`.
- **Modo não-interativo é cidadão de primeira classe.** Toda função de UI (`lib/interactive.sh`) tem um caminho para `BDW_NAO_INTERATIVO=1`. É o que torna os testes de integração em CI possíveis.

## O contrato de módulo

Um módulo é um arquivo `modules/<categoria>/<id>.sh`. Metadados no topo, cinco verbos obrigatórios:

```bash
BDW_MODULE_ID="docker"
BDW_MODULE_NOME="Docker Engine"
BDW_MODULE_DESC="Descrição curta exibida no catálogo"
BDW_MODULE_CATEGORIA="containers"
BDW_MODULE_DEPS=""              # ids de módulos dos quais este depende (espaço-separado)
BDW_MODULE_TIMEOUT=2700         # opcional; padrão é BDW_TIMEOUT_PADRAO (30 min)

module_compativel() { ... }   # este sistema suporta este módulo? (distro, GUI, systemd...)
module_verificar()  { ... }   # já está instalado e atualizado? (idempotência)
module_instalar()   { ... }   # instala pacotes/binários
module_configurar() { ... }   # aplica configuração (pode rodar mesmo após pulos parciais)
module_reverter()   { ... }   # desfaz o que module_instalar+module_configurar fizeram
```

Códigos de saída do runner (`lib/module.sh`), usados pelos orquestradores para decidir o resumo final:

| Código | Significado |
|---|---|
| `0` | Instalado com sucesso |
| `2` | Já estava instalado — pulado |
| `3` | Incompatível com este sistema — pulado |
| `124` | Tempo esgotado (`BDW_MODULE_TIMEOUT`) |
| outro | Falha — rollback já foi executado |

### Convenções observadas em todos os módulos

- **Nunca remover dependências do sistema operacional.** Ex: `python.sh` reverte `pipx`, mas mantém `python3` (dependência do próprio Ubuntu).
- **Dados do usuário nunca são apagados na reversão.** Ex: `docker.sh` remove o Engine mas mantém `/var/lib/docker`; `postgresql.sh` remove o container mas mantém o volume.
- **Chaves e credenciais nunca são sobrescritas silenciosamente.** `ssh.sh` gera uma chave apenas se não existir.
- **Comandos com strict mode incompatível (NVM, SDKMAN) rodam em `bash -c '...'` isolado**, nunca no shell principal do módulo (que roda sob `set -Eeuo pipefail`).

## Resolução de dependências

`mod_resolver_dependencias` faz uma ordenação topológica (DFS com detecção de ciclo) sobre `BDW_MODULE_DEPS`. Ao pedir `docker-compose`, o resultado inclui `docker` antes, na ordem correta de execução — sem exigir que o usuário liste dependências manualmente.

## Abstração de pacotes

`lib/packages.sh` despacha para o gerenciador da família de distro detectada (`BDW_DISTRO_FAMILIA`, calculado a partir de `ID`/`ID_LIKE` do `/etc/os-release`). Na v1.0 apenas a família `debian` (APT) está implementada; `fedora`, `arch` e `suse` retornam erro claro, preparando o terreno para as próximas versões sem reescrever os módulos.

## Manifesto de estado

`~/.local/state/brunodev/manifesto` é a fonte de verdade de "o que esta ferramenta instalou". Uma linha por módulo (`id|versão|data`). `update.sh` reprocessa cada linha (idempotente, então atualiza o que mudou). `uninstall.sh` oferece as linhas do manifesto para reversão seletiva.

## Testes

- **Unitários** (`tests/unit/*.bats`) rodam contra a lib real, com estado isolado por teste (`BDW_DIR_ESTADO`/`BDW_DIR_CONFIG` apontando para diretório temporário) e fixtures de módulo descartáveis para exercitar o runtime sem tocar no sistema real.
- **Integração** (`tests/integration/instalacao.sh`) roda dentro de `ubuntu:24.04` via Docker: instala o perfil `minimo`, valida artefatos, roda de novo para provar idempotência, desinstala, e valida `requirements.sh` isoladamente.
