# Big Bang

<!--
Badges generator https://badgesgenerator.com/
Simple Icons https://simpleicons.org/?q=ubuntu
-->

![macOS](https://img.shields.io/badge/macOS-first-green?labelColor=gray&style=flat&logo=apple&logoColor=white)

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

> 🌐 **🇧🇷 Português** · [🇺🇸 English](./README-en.md)

Configuração de máquina (macOS) versionada e roteirizada: **dotfiles, editor,
terminal e prompt** que você instala numa máquina nova com poucos comandos.
Faça um fork, ajuste o que é seu e rode `just bootstrap`.

## Índice

- [O que é isso](#o-que-é-isso)
- [Quick Start](#quick-start)
- [Pré-requisitos](#pré-requisitos)
- [Faça seu fork (torne seu)](#faça-seu-fork-torne-seu)
- [Setup passo a passo](#setup-passo-a-passo)
- [Comandos do dia a dia](#comandos-do-dia-a-dia)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Ferramentas / stack](#ferramentas--stack)
- [Como funciona por dentro](#como-funciona-por-dentro)
- [Troubleshooting / FAQ](#troubleshooting--faq)
- [Qualidade](#qualidade)
- [Licença](#licença)

## O que é isso

O projeto **Big Bang** é a minha fonte única de verdade para a configuração da
máquina: dotfiles, editor, terminal e prompt. O objetivo é **conveniência** —
quando configuro uma máquina nova ou reinstalo uma ferramenta, venho aqui pra
lembrar como o meu ambiente está montado e colocar os configs de volta no lugar.

> Um repositório de referência / dotfiles curado. O setup é roteirizado com
> [`just`](https://github.com/casey/just) (sem framework pesado de provisionamento).

**É pra você?** Foi pensado pra todo mundo. Seja pra uso pessoal ou profissional,
fique à vontade pra fazer um fork e adaptar como precisar. Repare que é um setup
**opinativo** (meu git, minhas chaves, minhas linguagens no Neovim) — então o
fluxo certo é forkar e [tornar seu](#faça-seu-fork-torne-seu) antes de rodar.

## Quick Start

Do Mac zerado ao ambiente pronto, copiando e colando de cima a baixo (primeira
vez? leia [Pré-requisitos](#pré-requisitos) e
[Faça seu fork](#faça-seu-fork-torne-seu) antes):

```sh
# 0. Xcode Command Line Tools (git, compiladores) — abre um diálogo; espere terminar
xcode-select --install

# 1. Homebrew + PATH nesta sessão (Intel: /usr/local/bin/brew)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. just
brew install just

# 3. clone via HTTPS (ainda não precisa de chave SSH) + bootstrap (idempotente)
git clone https://github.com/marcopollivier/big-bang.git ~/dev/marcopollivier/big-bang
cd ~/dev/marcopollivier/big-bang
just report      # opcional: o que já existe, o que falta e o que vai conflitar
just bootstrap

# 4. novo terminal → login no GitHub (gera/sobe a chave SSH) → valide
exec zsh
gh auth login --git-protocol ssh --web
git remote set-url origin git@github.com:marcopollivier/big-bang.git
just doctor
```

Depois disso, preencha identidade/segredos e a chave GPG — passo 3 do
[Setup passo a passo](#setup-passo-a-passo).

## Pré-requisitos

O que precisa existir **antes** do bootstrap — é pouco:

- **macOS** (Apple Silicon ou Intel), com um usuário **administrador** (o
  instalador do Homebrew pede `sudo`). O projeto é *macOS-first*.
- **Xcode Command Line Tools** — trazem o `git` e os compiladores que o
  Homebrew usa. O comando abre um diálogo do sistema; espere a instalação terminar:
  ```sh
  xcode-select --install
  ```
- **[Homebrew](https://brew.sh/)** — instale com o one-liner oficial e coloque-o
  no PATH da sessão atual (o instalador imprime isso no final):
  ```sh
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"   # Intel: eval "$(/usr/local/bin/brew shellenv)"
  ```
  Não precisa editar o `~/.zprofile`: o [`.zshrc`](./dotfiles/.zshrc) do repo
  já faz isso de forma permanente depois do `just link`.
- **Conta no GitHub.** **Chave SSH _não_ é pré-requisito:** numa máquina nova,
  clone via **HTTPS** (não pede autenticação para repo público). Depois do
  bootstrap, o `gh` (que vem no [`Brewfile`](./Brewfile)) cria e cadastra a
  chave SSH para você — veja o passo 4 do [Setup passo a passo](#setup-passo-a-passo).

Todo o resto (`gh`, `git-lfs`, `gnupg`, `mise`, oh-my-zsh, toolchains…) o
`just bootstrap` instala.

## Faça seu fork (torne seu)

Este repo carrega a **minha** identidade e as minhas escolhas. Antes de rodar o
bootstrap numa máquina sua, faça um **fork** e ajuste o que é pessoal. Nada aqui
tem segredo versionado — só *templates* — mas vários defaults são meus:

| O que ajustar | Onde | Por quê |
|---|---|---|
| **URL do clone** | troque `marcopollivier/big-bang` pelo seu fork | apontar para o *seu* repositório |
| **Identidade do git** | `~/.gitconfig` (após `just seed`) — `name`, `email`, `signingKey` | o template ([`dotfiles/.gitconfig`](./dotfiles/.gitconfig)) vem em branco |
| **Segredos da máquina** | `~/.zshrc.local` (após `just seed`) | `AWS_*`, `GITHUB_TOKEN`, ARNs de EKS, chave do WakaTime — veja [`.zshrc.local.example`](./dotfiles/.zshrc.local.example) |
| **WakaTime** | `~/.wakatime.cfg` | a sua API key (opcional; remova se não usa) |
| **Pacotes** | [`Brewfile`](./Brewfile) | tire/ponha apps e CLIs conforme o seu gosto |
| **Containers (trabalho vs pessoal)** | [`Brewfile`](./Brewfile) + bootstrap | no **trabalho**: podman (Docker Desktop tem licença comercial); na **máquina pessoal**: docker é ok — troque `brew "podman"` pelo cask `docker` (comentado no Brewfile) e o `just podman-machine` se auto-pula |
| **Linguagens do editor** | [`nvim/`](./nvim) | o Neovim vem pronto pra **Go, .NET/C# e Kotlin**; adapte os LSPs ao seu stack |
| **Toolchains** | [`mise/config.toml`](./mise/config.toml) | versões de Go/Java/Node/… que serão instaladas. Linguagens só da sua máquina (ex.: Clojure, Maven na pessoal) vão em `~/.config/mise/conf.d/*.toml`, fora do repo. Vindo do asdf? Tire a linha do asdf do shell e mova o `~/.tool-versions` da home (o mise lê esse arquivo e as versões dele passam por cima das do repo) |
| **Caminho do clone** | nenhum, se usar `just seed`/`just link` | o statusline do Claude ([`claude/settings.json`](./claude/settings.json)) e o status do WezTerm descobrem o clone sozinhos (fallback: convenção `~/dev/<github-user>/big-bang`); se algo falhar, defina `BIG_BANG_REPO` no `~/.zshrc.local` |
| **Token do npm** | `~/.npmrc` (após `just seed`) | o template ([`dotfiles/.npmrc`](./dotfiles/.npmrc)) lê `NPM_TOKEN` do ambiente — defina no `~/.zshrc.local` se usa registry privado |

> 💡 **Regra de ouro:** os arquivos com identidade/segredo são apenas *copiados*
> (`just seed`) e **nunca** sobrescritos nem versionados de volta — então pode
> editá-los à vontade na sua home. Detalhes em
> [Como funciona por dentro](#como-funciona-por-dentro).

## Setup passo a passo

**1. Instale os [Pré-requisitos](#pré-requisitos) (Xcode Command Line Tools
e Homebrew) e, em seguida, o `just`:**

```sh
brew install just
```

**2. Clone o seu fork (via HTTPS) e rode o bootstrap:**

```sh
git clone https://github.com/<você>/big-bang.git ~/dev/<você>/big-bang
cd ~/dev/<você>/big-bang
just report      # antes: o que o bootstrap vai fazer nesta máquina
just bootstrap
```

> 🔎 **Antes de rodar o bootstrap**, `just report` mostra o inventário da máquina:
> cada item do Brewfile, toolchain do mise, symlink e seed com status (`ok`,
> `missing` = vai instalar, `conflict` = já existe por fora do brew — ex.: app
> instalado à mão, resolva com `brew install --cask --adopt <cask>`), versão e
> **de onde veio**; mais o que está instalado fora do repo (brew extra, apps
> manuais/App Store, `/usr/local/bin`, `npm -g`). O relatório fica salvo em
> `~/.big-bang/reports/` (o `latest.md` é o último) e o bootstrap gera um novo
> no final — compare os dois com `diff`. `~/.big-bang/` é o estado **da máquina**
> e nunca vai pro repo.

> 📁 **Convenção de pastas:** projetos vivem em `~/dev/<dono>/<projeto>` — o
> dono é o usuário/org do GitHub (ex.: `~/dev/<você>/big-bang`). Só os dotfiles
> ficam na raiz da home (`~/`), via symlink/seed. Não é obrigatório (tudo se
> descobre sozinho, e `BIG_BANG_REPO` cobre exceções), mas é o padrão que o
> repo assume como fallback.

O `just bootstrap` é **idempotente** (pode rodar quantas vezes quiser) e executa:

- `just brew` — instala tudo que está no [`Brewfile`](./Brewfile)
- `just omz` — instala o oh-my-zsh, se faltar (o `.zshrc` depende dele)
- `just link` — cria os symlinks dos configs compartilhados (zsh, starship, nvim, mise…); arquivos reais existentes têm backup feito antes
- `just mise-install` — instala os toolchains do [`mise/config.toml`](./mise/config.toml)
- `just seed` — copia os templates de segredo/identidade **só se não existirem**: `.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`, `~/.npmrc`, `~/.aws/config`, `~/.clojure/deps.edn` e os do Claude Code (`~/.claude/settings.json`, `~/.claude/usage-budget` e `~/.claude/automode.local.json` — veja [`claude/`](./claude))
- `just automode` — grava a config do *auto mode* do Claude Code ([`claude/automode.json`](./claude/automode.json)) no `~/.claude/settings.json`
- `just gpg-agent` — aponta o `gpg-agent` para o `pinentry-mac` (senha da chave GPG numa janela do macOS, com opção de guardar no Keychain)
- `just podman-machine` — cria/inicia a VM Linux do podman (no macOS containers rodam dentro dela)
- `just report` — salva o inventário pós-bootstrap em `~/.big-bang/reports/`

**3. Preencha sua identidade e segredos** (veja a tabela em
[Faça seu fork](#faça-seu-fork-torne-seu)): nome/e-mail do git em `~/.gitconfig`,
chave do WakaTime em `~/.wakatime.cfg` e os segredos em `~/.zshrc.local`.

> 🔑 **Chave GPG — não pule esta etapa.** O `.gitconfig` vem com assinatura de
> commits **ligada** (`commit.gpgSign = true`); sem uma chave configurada, todo
> `git commit` falha. Crie a sua:
>
> ```sh
> gpg --full-generate-key                        # respostas abaixo
> gpg --list-secret-keys --keyid-format=long     # copie o ID após "sec ed25519/"
> git config --global user.signingkey <ID>
> gpg --armor --export <ID>                      # cole no GitHub → Settings → SSH and GPG keys
> ```
>
> Respostas do `gpg --full-generate-key`:
>
> | Pergunta | Resposta | Por quê |
> |---|---|---|
> | Tipo de chave | **`9` — ECC (de assinar e cifrar)**, o padrão | Gera ed25519 (assinatura) + cv25519 (cifra): chave curta, rápida e aceita pelo GitHub. Evite `16` (ECC e Kyber, pós-quântica): o GitHub ainda não aceita. `1`/`4` (RSA 4096) também funcionam, só são mais lentas e maiores. |
> | Curva | **`1` — Curve 25519**, o padrão | É a recomendada; NIST/Brainpool só por exigência de compliance. |
> | Validade | **`2y`** (ou `0` = nunca expira) | Expirar limita o estrago se a chave vazar. Renovar é um comando (`gpg --quick-set-expire <ID> 2y`) e reenviar a pública ao GitHub; commits antigos continuam verificados. |
> | Nome e e-mail | **Os mesmos do `~/.gitconfig`** | O GitHub só marca *Verified* se o e-mail da chave for um e-mail **verificado na sua conta**. |
> | Comentário | vazio | — |
> | Senha | uma senha forte | Veja abaixo: você não vai digitá-la a cada commit. |
>
> **A senha não é pedida a cada commit.** Ela só é usada para *assinar*, e o
> `just gpg-agent` (já incluso no `bootstrap`) configura o `pinentry-mac`: na
> primeira assinatura abre uma janela do macOS — marque **"Save in Keychain"** e
> ela passa a ser liberada sozinha enquanto você estiver logado. Sem o Keychain,
> o `gpg-agent` ainda guarda a senha em cache por alguns minutos.
>
> Não quer assinar commits? Desligue de vez:
> `git config --global commit.gpgsign false`

**4. Autentique no GitHub e configure a chave SSH** (usada para clone/push —
não confunda com a chave GPG acima, que só assina commits):

```sh
gh auth login --git-protocol ssh --web   # se não houver chave, o gh gera uma e cadastra no GitHub
git remote set-url origin git@github.com:<você>/big-bang.git   # troca o clone HTTPS para SSH
ssh -T git@github.com                    # deve responder "Hi <você>! …"
```

<details>
<summary>Prefere criar a chave SSH na mão?</summary>

```sh
ssh-keygen -t ed25519 -C "<seu-email>"   # aceite o caminho padrão (~/.ssh/id_ed25519)
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get ComputerName)"
# ou cole o conteúdo do .pub em GitHub → Settings → SSH and GPG keys
```

</details>

**5. Abra um novo terminal** (ou `exec zsh`) e **valide** que está tudo no lugar:

```sh
just doctor   # checa ferramentas, symlinks, identidade git + chave GPG, Brewfile, cmux e VM do podman
```

> 🏢 Em **Mac gerenciado** (MDM) ou **atrás de proxy corporativo (Zscaler)**, alguns
> passos pedem ajuste — veja [Troubleshooting / FAQ](#troubleshooting--faq).

## Comandos do dia a dia

Rode `just` (sem argumentos) para listar todas as recipes. As mais usadas:

| Comando | O que faz |
|---|---|
| `just` | lista todas as recipes disponíveis |
| `just bootstrap` | setup completo de máquina nova (idempotente) |
| `just doctor` | checa ferramentas, symlinks, identidade git + chave GPG, divergência do Brewfile, config do Claude Code (auto mode + statusline), versão do cmux e a VM do podman |
| `just report` | inventário da máquina (status, versão e origem de cada item; conflitos com o que foi instalado à mão) em `~/.big-bang/reports/` |
| `just link` | reaplica os symlinks (rode após adicionar um config novo) |
| `just brew` | instala/atualiza os pacotes do [`Brewfile`](./Brewfile) |
| `just brew-dump` | atualiza o `Brewfile` a partir do que está instalado |
| `just clean-backups` | lista os `.bak.*` que o `just link` deixou (apaga com `just clean-backups yes`) |
| `just mise-install` | instala os toolchains do [`mise/config.toml`](./mise/config.toml) |
| `just seed` | copia os templates de identidade/segredo (só se faltarem) |
| `just automode` | reaplica a config do auto mode do Claude Code (repo + `~/.claude/automode.local.json`) |
| `just cmux-settings` | liga no cmux o que só existe na UI (Extensions beta = botão de plugins) |
| `just gpg-agent` | configura o `pinentry-mac` no `~/.gnupg/gpg-agent.conf` (só se não houver outro pinentry) |
| `just podman-machine` | cria/inicia a VM Linux do podman |
| `just pr` | abre um PR da branch atual no navegador (requer `gh auth login`) |
| `just ruflo` | instala o plugin ruflo do Claude Code (requer a CLI `claude`) |

> ⚠️ **Não dê push direto na `main`.** Trabalhe em branch e abra PR com `just pr`.

## Estrutura do repositório

| Pasta | O que vive aqui |
|---|---|
| [`dotfiles/`](./dotfiles) | Dotfiles da home (`.zshrc`, `.gitconfig`, `.wakatime.cfg`, configs de AWS/Clojure/OpenTofu…). Templates **sem segredos** versionados. |
| [`nvim/`](./nvim) | Neovim como IDE para **Go, .NET/C# e Kotlin** (lazy.nvim, LSP via Mason, Claude Code + WakaTime). Veja o [`SETUP.md`](./nvim/SETUP.md). |
| [`wezterm/`](./wezterm) | Configuração do terminal [WezTerm](https://wezfurlong.org/wezterm/). |
| [`starship/`](./starship) | Configuração do prompt [Starship](https://starship.rs/). |
| [`mise/`](./mise) | Config global do [mise](https://mise.jdx.dev/) — versões dos toolchains. |
| [`claude/`](./claude) | Config do [Claude Code](https://claude.com/claude-code) + acompanhamento de consumo de tokens (statusline e status do mês no WezTerm). Veja o [`README`](./claude/README.md). |
| [`cmux/`](./cmux) | Orquestrador de agentes de IA (terminal Ghostty embutido), em teste como alternativa ao WezTerm. Veja o [`README`](./cmux/README.md). |
| [`defaultdots/`](./defaultdots) | Dotfiles originais/de fábrica, mantidos como referência de reset. |
| [`scripts/`](./scripts) | Scripts maiores chamados pelo `justfile` — ex.: `report.sh` (`just report`). |

Cada pasta tem o seu próprio `README.md`. Arquivos da raiz que vale conhecer:

- [`justfile`](./justfile) — comandos de bootstrap e manutenção (`just`).
- [`Brewfile`](./Brewfile) — pacotes do Homebrew (`brew bundle`).
- [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) — hooks locais de qualidade/segredos.
- [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) — CI (lint, sintaxe, scan de segredos).
- `.claude/` — slash commands para quem usa o Claude Code no repo:
  **`/setup-machine`** (configura a máquina do zero, guiado) e **`/sync`**
  (re-sincroniza symlinks/Brewfile e reporta divergências).

## Ferramentas / stack

- **Gerenciador de versões:** [mise](https://mise.jdx.dev/) — Go, Java, Kotlin,
  Node, .NET… (substituiu asdf/nvm/pyenv). Veja o [`mise/config.toml`](./mise/config.toml).
- **Pacotes:** [Homebrew](https://brew.sh/) (veja o [`Brewfile`](./Brewfile)).
- **Shell:** zsh + oh-my-zsh, prompt **Starship**.
- **Editor:** Neovim (veja [`nvim/`](./nvim)).
- **CLIs do dia a dia:** lazygit, lazydocker, fzf, bat, eza, awscli, kubectl, argocd, opentofu.

## Como funciona por dentro

Não precisa entender esta seção pra usar o projeto — ela explica *por que* o
setup é seguro e por que editar de qualquer lado "simplesmente funciona".

### Symlinks (links simbólicos)

Os configs deste repo **não são copiados** para a sua home — eles são
**symlinkados**. Um symlink é um ponteiro: o arquivo na sua home (ex.: `~/.zshrc`)
é só um atalho para o arquivo real dentro do repo
(`big-bang/dotfiles/.zshrc`). Existe apenas **um** arquivo real.

```
~/.zshrc  ──▶  ~/<seu-dir>/big-bang/dotfiles/.zshrc   (o arquivo real, versionado)
```

O `just link` cria esses links (veja o [`justfile`](./justfile)). Ele é
**idempotente** — links já corretos são deixados intactos e, se um arquivo
*real* já estiver no lugar, é feito um backup em `<arquivo>.bak.<timestamp>`
antes de o link substituí-lo, então nada nunca é perdido.

#### É automático

Como a home e o repo apontam para o mesmo arquivo, **editar de qualquer um dos
lados atualiza os dois de uma vez** — não existe passo de sincronização:

- Edite `~/.config/nvim/init.lua` → o repo já enxerga a mudança, pronta pra commitar.
- `git pull` de uma mudança feita em outra máquina → ela já está valendo na sua home.

Pra reaplicar ou consertar os links depois de adicionar um config novo, é só
rodar `just link` de novo.

> ⚠️ **Efeito colateral do symlink:** instaladores que fazem `>> ~/.zshrc`
> (muitos CLIs fazem) escrevem **direto no arquivo versionado do repo**. Antes
> de commitar, confira o `git diff` — mova o que for específico da máquina para
> `~/.zshrc.local` em vez de deixar no `.zshrc` do repo.

### Como ele se mantém seguro (sem vazar segredos)

O truque é que **só arquivos sem segredo são symlinkados e versionados**.
Tudo que carrega identidade ou credenciais é tratado de outro jeito:

| Tipo de arquivo | Estratégia | Versionado? | Exemplos |
|---|---|---|---|
| Config compartilhado, **sem segredo** | **symlink** (`just link`) | ✅ sim | `.zshrc`, `starship.toml`, `nvim/`, `mise/config.toml` |
| Com identidade / segredo | **seed** — copiado **só se faltar** (`just seed`), nunca sobrescreve | ❌ não | `.gitconfig`, `.wakatime.cfg`, `.npmrc` |
| Puramente segredos / específico da máquina | mantido num arquivo **git-ignored** que você preenche à mão | ❌ não | `~/.zshrc.local` |

Então a proteção em camadas é:

1. **Nenhum segredo nos templates symlinkados.** Os configs versionados leem os
   segredos do ambiente (ex.: o `~/.zshrc` faz
   `[ -f ~/.zshrc.local ] && source ~/.zshrc.local`) em vez de fixá-los no código.
2. **O `just seed` nunca sobrescreve.** Arquivos que guardam identidade são
   *copiados* uma vez e depois ignorados — o seu `~/.gitconfig` real nunca é
   linkado de volta pro repo, então não tem como ser commitado por acidente.
3. **O `~/.zshrc.local` é git-ignored** e nunca sai da sua máquina. Comece a
   partir do [`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example).
4. **Defesa em profundidade:** o [gitleaks](./.github/workflows/ci.yml) roda no
   CI e os [hooks de pre-commit](./.pre-commit-config.yaml) varrem por segredos,
   então uma credencial vazada por acidente é barrada antes de ir pro push.

**Regra de bolso:** se um arquivo contém um segredo, ele *não* pode ser
symlinkado — coloque o segredo em `~/.zshrc.local` e referencie a partir de um
template versionado.

### Onde ficam os segredos

**Nenhuma credencial é versionada.** Valores específicos da máquina e segredos
(`AWS_*`, `GITHUB_TOKEN`, ARNs dos clusters EKS, chave de API do WakaTime, …)
ficam em `~/.zshrc.local`, que é git-ignored. Use o
[`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example) como template.

## Troubleshooting / FAQ

### `podman pull` falha com `x509: certificate signed by unknown authority`

Acontece em máquina gerenciada com **Zscaler** (inspeção de TLS): a VM do podman
não confia no CA do Zscaler. O fix é injetar o root CA (que já está no keychain
do macOS) na trust store da VM:

```sh
# exporta o root CA do Zscaler do System keychain
security find-certificate -a -c "Zscaler Root CA" -p /Library/Keychains/System.keychain > /tmp/zscaler-root-ca.crt

# copia para dentro da VM e atualiza a trust store
podman machine ssh 'cat > /tmp/zscaler-root-ca.crt' < /tmp/zscaler-root-ca.crt
podman machine ssh 'sudo cp /tmp/zscaler-root-ca.crt /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust'
```

> ⚠️ É **efêmero**: se a VM for recriada (`podman machine rm` + `init`), repita o passo.

### Ferramentas que falam com o socket padrão do Docker (testcontainers, etc.)

Instale o helper uma vez:

```sh
sudo $(brew --prefix)/bin/podman-mac-helper install && podman machine stop && podman machine start
```

### `brew install --cask <app>` pede senha / falha em Mac gerenciado

Em Mac **gerenciado por MDM**, `/Applications` pertence ao root e o seu usuário
não tem escrita lá. Instalar um cask de app GUI cai num `sudo cp` e exige a senha
de forma **interativa** — então rode você mesmo, num terminal:

```sh
brew install --cask visual-studio-code
```

Casks de CLI/fonts (que não vão para `/Applications`) instalam normalmente.

## Qualidade

- **CI** ([`ci.yml`](./.github/workflows/ci.yml)): sintaxe do zsh, formatação Lua
  (stylua), validação do justfile e scan de segredos (gitleaks) em todo push/PR.
- **Hooks locais** ([`.pre-commit-config.yaml`](./.pre-commit-config.yaml)):
  `brew install pre-commit && pre-commit install`.
- **Formatação:** [`.editorconfig`](./.editorconfig) + [`.stylua.toml`](./.stylua.toml).

## Licença

Este projeto é licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.
</content>
</invoke>
