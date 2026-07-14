---
name: Relatar um bug
about: Algo não funcionou como esperado
title: "[bug] "
labels: bug
---

## Descrição

Descreva o que aconteceu.

## Como reproduzir

1. Comando executado: `./install.sh ...`
2. Módulo/perfil envolvido:
3. Passo a passo até o erro:

## Comportamento esperado

O que deveria ter acontecido.

## Ambiente

- Distribuição e versão: `cat /etc/os-release | head -4`
- Versão do BrunoDev Workstation: `./install.sh --versao`
- Kernel: `uname -r`

## Log da sessão

Cole as últimas 100 linhas do log:

```bash
tail -100 ~/.local/state/brunodev/logs/install-*.log
```

Ou cole o resumo:

```bash
cat ~/.local/state/brunodev/ultimo-resumo.txt
```

## Contexto adicional

Qualquer outra informação relevante.
