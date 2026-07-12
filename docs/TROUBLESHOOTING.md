# Solução de Problemas

## "Distribuição não suportada"

O `requirements.sh` verificou `/etc/os-release` e sua distribuição/versão não está na lista suportada pela v1.0 (apenas Ubuntu 24.04+). Veja o [ROADMAP](ROADMAP.md) para saber quando sua distro chega. Não há como contornar isso manualmente — os módulos usam `apt` diretamente e assumem a estrutura do Ubuntu.

## "Não execute como root"

Rode o instalador como seu usuário normal, sem `sudo` na frente do comando. O script pede `sudo` internamente apenas quando um módulo precisa. Rodar como root quebra a detecção de `$HOME`, grupos de usuário (ex: grupo `docker`) e configurações de dotfiles.

## Docker: "permission denied" após instalar

O módulo `docker` adiciona seu usuário ao grupo `docker`, mas isso só tem efeito em uma **nova sessão de shell**. Abra um novo terminal ou rode `newgrp docker` na sessão atual.

## "docker: command not found" dentro de um módulo de banco de dados

Os módulos `postgresql`/`redis`/`mysql` chamam `docker` com `sudo` internamente (via `como_root`) justamente para não depender do grupo já estar ativo na sessão. Se ainda assim falhar, confirme que o módulo `docker` foi instalado com sucesso: `sudo docker info`.

## Extensões do VS Code não instalam

Verifique se o comando `code` está no PATH após a instalação (`command -v code`). Se o módulo `vscode` foi pulado por incompatibilidade, é porque não há sessão gráfica ativa (`XDG_SESSION_TYPE` vazio) — normal em servidores/containers.

## Ghostty não encontrou um `.deb` para minha versão do Ubuntu

O módulo busca dinamicamente na última release do projeto [ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) um pacote compatível com `$BDW_DISTRO_VERSAO`. Se o projeto ainda não publicou build para uma versão muito recente do Ubuntu, aguarde ou instale manualmente seguindo a documentação oficial do Ghostty.

## SDKMAN/NVM: comandos "não encontrados" logo após a instalação

NVM e SDKMAN modificam o shell via arquivos de inicialização (`~/.zshrc`/`~/.bashrc`). Abra um novo terminal — o módulo `shell` já carrega ambos no `.zshrc` gerenciado, mas a sessão atual não é recarregada automaticamente.

## Instalação travou / demorou demais

Cada módulo tem um timeout (30 minutos por padrão, alguns maiores como Ollama e VS Code). Se um módulo estourar o timeout, o instalador registra falha (`código 124`) e pergunta se deseja continuar com os demais. Verifique sua conexão de internet e o log da sessão em `~/.local/state/brunodev/logs/`.

## Quero reinstalar um módulo do zero

```bash
./uninstall.sh          # selecione o módulo específico
./install.sh --modulos <id>
```

## Quero ver exatamente o que um módulo faz antes de instalar

Todo módulo é um arquivo de texto simples: `modules/<categoria>/<id>.sh`. Leia-o — é bash comum, sem ofuscação, com os cinco verbos (`module_compativel`, `module_verificar`, `module_instalar`, `module_configurar`, `module_reverter`) claramente separados.

## Firewall (UFW) me trancou fora via SSH

O módulo `firewall` libera automaticamente a porta SSH **se o pacote `openssh-server` já estiver instalado no momento da configuração**. Se você instalou o SSH server depois de ativar o firewall, libere manualmente: `sudo ufw allow OpenSSH`.

## Nada disso resolveu

Abra uma [issue](https://github.com/BrunoSouzaFarias/brunodev-workstation/issues) com a saída de `./install.sh --versao`, `cat /etc/os-release` e o log da sessão relevante em `~/.local/state/brunodev/logs/`.
