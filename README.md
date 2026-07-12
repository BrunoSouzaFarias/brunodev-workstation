# BrunoDev Workstation

**Transforme uma instalação limpa do Linux em uma workstation completa de desenvolvimento, DevOps e Inteligência Artificial — com um único comando.**

Inspirado em ferramentas como [Omakub](https://omakub.org), Homebrew e Oh My Zsh, mas construído do zero como um produto: modular, idempotente, reversível e com testes automatizados.

## Instalação

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/BrunoSouzaFarias/brunodev-workstation/main/install.sh)
```

Ou, clonando o repositório:

```bash
git clone https://github.com/BrunoSouzaFarias/brunodev-workstation
cd brunodev-workstation
./install.sh
```

O instalador abre uma interface interativa: detecta seu sistema, sugere um perfil e permite ajustar módulo por módulo antes de instalar qualquer coisa.

```bash
./install.sh --perfil ai-engineer     # instala um perfil pronto, sem TUI extra
./install.sh --modulos docker,vscode  # instala apenas módulos específicos
./install.sh --listar                 # lista o catálogo completo de módulos
./install.sh --perfis                 # lista os perfis disponíveis
```

## Por que este projeto existe

Montar uma workstation de desenvolvimento do zero é repetitivo e propenso a erro: instalar runtimes, configurar Git e SSH, subir bancos de dados, ajustar o shell, instalar ferramentas de IA... O BrunoDev Workstation automatiza esse processo inteiro, de forma seguro para rodar mais de uma vez (idempotente) e fácil de desfazer.

## Requisitos (v1.0)

| Requisito | Mínimo |
|---|---|
| Distribuição | Ubuntu 24.04 LTS ou superior |
| Disco livre | 10 GB |
| RAM | 4 GB (recomendado para módulos de IA local) |
| Internet | Necessária durante a instalação |
| Privilégios | Usuário normal com acesso a `sudo` (nunca rode como root) |

Outras distribuições chegam nas próximas versões — veja o [ROADMAP](docs/ROADMAP.md).

## Perfis prontos

| Perfil | Para quem |
|---|---|
| `developer` | Base sólida para qualquer desenvolvedor |
| `web` | Desenvolvimento web moderno (front + APIs) |
| `backend` | APIs, serviços e bancos de dados |
| `frontend` | Interfaces e tooling JS/TS |
| `devops` | Containers, automação e segurança |
| `ai-engineer` | IA local (Ollama) e assistentes de código |
| `data-science` | Python, dados e bancos |
| `java` | Ecossistema JVM completo (Maven, Gradle) |
| `android` | Base Java/Gradle (Android Studio na v2.0) |
| `fullstack` | Front + back + bancos |
| `completo` | Todos os módulos disponíveis |
| `custom` | Você escolhe módulo por módulo na TUI |

Detalhes de cada módulo em [docs/MODULOS.md](docs/MODULOS.md).

## Como funciona

1. **Detecção automática** — distribuição, CPU, GPU (NVIDIA/AMD/Intel), RAM, tipo de disco, Secure Boot, Wayland/X11, VM, laptop ou desktop.
2. **Seleção** — perfil pronto ou seleção manual de módulos numa TUI (via [gum](https://github.com/charmbracelet/gum), com fallback em texto puro).
3. **Resolução de dependências** — módulos com pré-requisitos (ex: `docker-compose` depende de `docker`) são ordenados automaticamente.
4. **Instalação idempotente** — cada módulo verifica se já está instalado e atualizado antes de agir; rodar o instalador de novo nunca duplica trabalho.
5. **Rollback automático** — se um módulo falhar no meio da instalação, as ações já executadas por ele são desfeitas.
6. **Manifesto de estado** — tudo o que foi instalado fica registrado em `~/.local/state/brunodev/manifesto`, usado pelo `update.sh` e `uninstall.sh`.

```bash
./update.sh      # atualiza a ferramenta e reprocessa os módulos instalados
./uninstall.sh   # remove módulos selecionados, revertendo o que fizeram
```

## Arquitetura

Um resumo rápido: a lógica compartilhada vive em `lib/` (detecção, pacotes, TUI, runtime de módulos), cada funcionalidade instalável é um módulo independente em `modules/<categoria>/<id>.sh`, e `install.sh` orquestra tudo. Detalhes completos, incluindo o contrato que todo módulo deve seguir, em [docs/ARQUITETURA.md](docs/ARQUITETURA.md).

## Contribuindo

Contribuições são bem-vindas — desde um novo módulo até a correção de um typo. Veja [CONTRIBUTING.md](CONTRIBUTING.md) para o guia completo (padrões de código, como testar localmente, como adicionar um módulo).

## Documentação

- [docs/ARQUITETURA.md](docs/ARQUITETURA.md) — decisões de design e contrato de módulo
- [docs/MODULOS.md](docs/MODULOS.md) — catálogo completo de módulos
- [docs/ROADMAP.md](docs/ROADMAP.md) — o que vem nas próximas versões
- [docs/FAQ.md](docs/FAQ.md) — perguntas frequentes
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — problemas comuns e soluções
- [CHANGELOG.md](CHANGELOG.md) — histórico de versões

## Licença

[MIT](LICENSE) — use, modifique e distribua livremente.
