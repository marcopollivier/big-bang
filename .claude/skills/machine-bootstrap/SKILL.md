---
name: machine-bootstrap
description: Use quando o usuário quiser configurar/preparar uma máquina nova (macOS) a partir deste repositório de dotfiles, fazer o bootstrap do ambiente, reinstalar o setup ou re-sincronizar os configs. Cobre Homebrew, just, mise, symlinks, segredos e validação.
---

# Bootstrap de máquina (macOS) com o Big Bang

Este repositório é a fonte de verdade do ambiente. O objetivo é deixar uma máquina
nova pronta com o mínimo de esforço, sem expor segredos.

## Princípios
- **Nunca invente nem commite segredos.** Identidade/credenciais vão para
  `~/.zshrc.local` (gitignored) — peça os valores ao usuário.
- `just link` symlinka os configs compartilhados (faz backup do que for arquivo real).
- `just seed` copia templates de identidade/segredo **só se não existirem**.
- Confirme passos destrutivos antes de rodar.

## Passos

1. **Pré-requisitos**
   - Homebrew instalado? Se não, instale (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`).
   - `brew install just`

2. **Bootstrap** (na raiz do repo)
   - `just bootstrap` = `brew` (instala o Brewfile) → `link` → `mise-install` → `seed`.
   - `mise-install` já roda `mise trust` no `mise/config.toml` do repo, então entrar na
     pasta não dispara o erro de config não confiada. Se mesmo assim aparecer
     `Config files ... are not trusted`, rode `mise trust mise/config.toml`.
   - Se algo falhar, rode as recipes individuais (`just brew`, `just link`, etc.) e investigue.

3. **Identidade e segredos** (peça ao usuário; não preencha sozinho)
   - Git: `git config --global user.name`, `user.email`, `user.signingkey` (assinatura GPG está ligada no `.gitconfig`).
   - `~/.zshrc.local`: `AWS_*`, `GITHUB_TOKEN`, `EKS_PRD_ARN`, `EKS_HML_ARN` — modelo em `dotfiles/.zshrc.local.example`.
   - WakaTime: dentro do `nvim`, `:WakaTimeApiKey` (chave em https://wakatime.com/settings/api-key).

4. **Autenticações interativas** (não dá pra rodar headless)
   - `gh auth login` — peça ao usuário rodar com `! gh auth login --git-protocol ssh --web`.

5. **Validação**
   - `just doctor` — ferramentas no PATH + symlinks resolvidos.
   - Abra o `nvim` uma vez: o lazy.nvim instala os plugins e o Mason os LSPs/formatadores.
   - Abra uma shell nova: confira o prompt do **starship** e os aliases (`vim`→nvim, `ls`→eza).

6. **Fechamento**
   - Resuma o que ficou pronto e o que ainda depende do usuário (segredos, GPG, etc.).
   - Se o usuário tiver instalado ferramentas novas que deveriam ser versionadas, sugira `just brew-dump`.

## Manutenção (máquina já configurada)
- `just link` reaplica symlinks · `just doctor` checa estado · `just brew` atualiza pacotes.
- PRs: `just pr`. Nunca push direto na `main`.
