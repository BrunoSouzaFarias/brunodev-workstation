# Perguntas Frequentes

**Posso rodar o instalador mais de uma vez?**
Sim — é o comportamento esperado. Todo módulo verifica se já está instalado e atualizado antes de agir (`module_verificar`). Rodar de novo nunca duplica trabalho; é assim que `./update.sh` funciona.

**Preciso rodar como root?**
Não, e o instalador recusa se você tentar (`requirements.sh` bloqueia execução como root fora de containers). Rode como usuário normal — o `sudo` é solicitado apenas quando necessário, com uma sessão mantida viva durante toda a instalação.

**O que acontece se um módulo falhar no meio da instalação?**
As ações daquele módulo específico são revertidas automaticamente (rollback em pilha). Você é perguntado se quer continuar com os módulos restantes ou parar ali. Módulos já instalados com sucesso não são afetados.

**Como desinstalo algo que instalei por engano?**
`./uninstall.sh` — ele lista os módulos registrados no manifesto (`~/.local/state/brunodev/manifesto`) e permite escolher o que remover. Dados do usuário (chaves SSH, volumes de banco de dados, backups) nunca são apagados automaticamente; a saída do comando avisa o que foi preservado.

**Onde ficam os logs da instalação?**
`~/.local/state/brunodev/logs/`. Cada execução gera um arquivo com timestamp. O caminho do log da sessão atual é exibido ao final do resumo.

**Por que os bancos de dados rodam em Docker em vez de instalação nativa?**
Facilita resetar, trocar de versão ou remover completamente sem deixar rastros no sistema, e evita conflitos entre versões diferentes de Postgres/MySQL que outros projetos possam exigir. As portas são expostas apenas em `localhost` por segurança.

**Posso usar em uma distribuição diferente de Ubuntu 24.04?**
Na v1.0, não — o instalador recusa com uma mensagem clara. Fedora, Pop!_OS, Debian, Arch e outras chegam nas próximas versões; veja o [ROADMAP](ROADMAP.md).

**O instalador funciona sem interface gráfica (servidor)?**
Sim, para módulos que não dependem de GUI. Módulos como `vscode`, `terminal` (Ghostty) e `apps` detectam a ausência de sessão gráfica (`XDG_SESSION_TYPE`) e são pulados automaticamente como incompatíveis, sem interromper a instalação dos demais.

**Como instalo sem nenhuma interação (CI, scripts)?**
`./install.sh --perfil <nome> --sim`. O modo não-interativo assume "sim" para todas as confirmações e usa os valores padrão em prompts de texto.

**Meu VS Code/Ghostty não aparece na lista de módulos. Por quê?**
Módulos gráficos exigem sessão gráfica ativa (`module_compativel` verifica isso). Se você está numa sessão SSH sem X11 forwarding ou num servidor headless, esses módulos ficam marcados como incompatíveis — não é um bug.

**Como atualizo apenas a ferramenta, sem reinstalar módulos?**
`./update.sh` faz as duas coisas: atualiza o próprio BrunoDev Workstation (`git pull`) e reprocessa os módulos do manifesto (que, sendo idempotentes, só atualizam o que realmente mudou).

Não encontrou sua pergunta? Veja [TROUBLESHOOTING.md](TROUBLESHOOTING.md) ou abra uma [issue](https://github.com/BrunoSouzaFarias/brunodev-workstation/issues).
