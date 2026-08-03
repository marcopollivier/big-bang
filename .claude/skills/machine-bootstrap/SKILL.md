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

0. **Contexto da máquina** (pergunte ANTES do bootstrap — use AskUserQuestion)
   O setup varia entre máquina de **trabalho** e **pessoal**. Pergunte:
   - **Trabalho ou pessoal?** Deriva os defaults das duas perguntas seguintes.
   - **Containers: podman ou docker?**
     - *Trabalho* → **podman** (Docker Desktop tem licença comercial). Fluxo
       normal: o Brewfile já traz `podman` e o bootstrap roda `just podman-machine`.
     - *Pessoal* → **docker** é ok. Nesse caso: remova/ignore `podman` no
       Brewfile, sugira `! brew install --cask docker` (cask pede senha), e o
       `just podman-machine` se auto-pula quando o podman não está instalado.
       O alias comentado `docker=podman` do `.zshrc` NÃO se aplica.
   - **Linguagens além de Go/.NET?** (Kotlin, Java, Clojure, Node…)
     Hoje o default cobre Go + .NET (+ Kotlin em potencial). Para as demais,
     oriente onde ligar cada uma: toolchain no `mise/config.toml`, seção
     guardrail correspondente no `dotfiles/.zshrc`, LSP no `nvim/` se for editar.

1. **Pré-requisitos**
   - Homebrew instalado? Se não, instale (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`).
   - `brew install just`

2. **Bootstrap** (na raiz do repo)
   - `just bootstrap` compõe as sub-recipes na ordem do `justfile` — hoje:
     `brew` (Brewfile) → `link` (symlinks) → `mise-install` → `seed` →
     `podman-machine` (cria/inicia a VM Linux do podman). Confira `just --list`
     se a composição mudar.
   - `mise-install` já roda `mise trust` no `mise/config.toml` do repo, então entrar na
     pasta não dispara o erro de config não confiada. Se mesmo assim aparecer
     `Config files ... are not trusted`, rode `mise trust mise/config.toml`.
   - Se algo falhar, rode as recipes individuais (`just brew`, `just link`, etc.) e investigue.

3. **Identidade e segredos** (peça ao usuário; não preencha sozinho)
   - Git: `git config --global user.name`, `user.email`, `user.signingkey`.
   - **Chave GPG (obrigatório antes do primeiro commit):** a assinatura vem
     ligada no `.gitconfig` (`commit.gpgSign = true`), então sem chave todo
     `git commit` falha. Guie o usuário:
     1. `gpg --full-generate-key` (interativo — peça pra rodar com `!` se preciso; RSA 4096, e-mail igual ao do git)
     2. `gpg --list-secret-keys --keyid-format=long` → copiar o ID depois de `sec rsa4096/`
     3. `git config --global user.signingkey <ID>`
     4. Cadastrar a chave pública no GitHub: `gpg --armor --export <ID>` → Settings → SSH and GPG keys
     - Se o usuário **não quiser assinar**: `git config --global commit.gpgsign false` e pronto.
   - `~/.zshrc.local`: `AWS_*`, `GITHUB_TOKEN`, `EKS_PRD_ARN`, `EKS_HML_ARN` — modelo em `dotfiles/.zshrc.local.example`.
   - WakaTime: dentro do `nvim`, `:WakaTimeApiKey` (chave em https://wakatime.com/settings/api-key).
   - Claude Code: limite mensal (US$) em `~/.claude/usage-budget` — trabalho: o
     limite dado; pessoal/Pro: `0` (mostra só o gasto). Opcional: `just ruflo`
     instala o plugin ruflo (requer a CLI `claude`).

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
