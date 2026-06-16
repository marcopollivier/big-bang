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

Pra quem já sabe o que está fazendo (primeira vez? pule para
[Faça seu fork](#faça-seu-fork-torne-seu) antes):

```sh
# 1. Homebrew (se ainda não tiver) → https://brew.sh
# 2. just
brew install just

# 3. clone + bootstrap (idempotente)
git clone git@github.com:marcopollivier/big-bang.git && cd big-bang
just bootstrap

# 4. preencha identidade/segredos e valide
just doctor
```

## Pré-requisitos

- **macOS** (Apple Silicon ou Intel). O projeto é *macOS-first*.
- **Xcode Command Line Tools** — necessárias para o git e o Homebrew:
  ```sh
  xcode-select --install
  ```
- **[Homebrew](https://brew.sh/)** instalado (o `just bootstrap` cuida do resto
  dos pacotes a partir do [`Brewfile`](./Brewfile)).
- Uma chave SSH no GitHub (para clonar via `git@github.com:…`) ou use a URL HTTPS.

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
| **Linguagens do editor** | [`nvim/`](./nvim) | o Neovim vem pronto pra **Go, .NET/C# e Kotlin**; adapte os LSPs ao seu stack |
| **Toolchains** | [`mise/config.toml`](./mise/config.toml) | versões de Go/Java/Node/… que serão instaladas |

> 💡 **Regra de ouro:** os arquivos com identidade/segredo são apenas *copiados*
> (`just seed`) e **nunca** sobrescritos nem versionados de volta — então pode
> editá-los à vontade na sua home. Detalhes em
> [Como funciona por dentro](#como-funciona-por-dentro).

## Setup passo a passo

**1. Instale o [Homebrew](https://brew.sh/) e, em seguida, o `just`:**

```sh
brew install just
```

**2. Clone o seu fork e rode o bootstrap:**

```sh
git clone git@github.com:<você>/big-bang.git && cd big-bang
just bootstrap
```

O `just bootstrap` é **idempotente** (pode rodar quantas vezes quiser) e executa:

- `just brew` — instala tudo que está no [`Brewfile`](./Brewfile)
- `just link` — cria os symlinks dos configs compartilhados (zsh, starship, nvim, mise…); arquivos reais existentes têm backup feito antes
- `just mise-install` — instala os toolchains do [`mise/config.toml`](./mise/config.toml)
- `just seed` — copia os templates de segredo/identidade (`.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`) **só se não existirem**
- `just podman-machine` — cria/inicia a VM Linux do podman (no macOS containers rodam dentro dela)

**3. Preencha sua identidade e segredos** (veja a tabela em
[Faça seu fork](#faça-seu-fork-torne-seu)): nome/e-mail do git em `~/.gitconfig`,
chave do WakaTime em `~/.wakatime.cfg` e os segredos em `~/.zshrc.local`.

**4. Abra um novo terminal** (ou `exec zsh`) e **valide** que está tudo no lugar:

```sh
just doctor   # checa ferramentas + symlinks + VM do podman
```

> 🏢 Em **Mac gerenciado** (MDM) ou **atrás de proxy corporativo (Zscaler)**, alguns
> passos pedem ajuste — veja [Troubleshooting / FAQ](#troubleshooting--faq).

## Comandos do dia a dia

Rode `just` (sem argumentos) para listar todas as recipes. As mais usadas:

| Comando | O que faz |
|---|---|
| `just` | lista todas as recipes disponíveis |
| `just bootstrap` | setup completo de máquina nova (idempotente) |
| `just doctor` | checa ferramentas, symlinks e a VM do podman |
| `just link` | reaplica os symlinks (rode após adicionar um config novo) |
| `just brew` | instala/atualiza os pacotes do [`Brewfile`](./Brewfile) |
| `just brew-dump` | atualiza o `Brewfile` a partir do que está instalado |
| `just mise-install` | instala os toolchains do [`mise/config.toml`](./mise/config.toml) |
| `just seed` | copia os templates de identidade/segredo (só se faltarem) |
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
| [`defaultdots/`](./defaultdots) | Dotfiles originais/de fábrica, mantidos como referência de reset. |

Cada pasta tem o seu próprio `README.md`. Arquivos da raiz que vale conhecer:

- [`justfile`](./justfile) — comandos de bootstrap e manutenção (`just`).
- [`Brewfile`](./Brewfile) — pacotes do Homebrew (`brew bundle`).
- [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) — hooks locais de qualidade/segredos.
- [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) — CI (lint, sintaxe, scan de segredos).

## Ferramentas / stack

- **Gerenciador de versões:** [mise](https://mise.jdx.dev/) — Go, Java, Kotlin,
  Node, .NET, Python… (substituiu asdf/nvm/pyenv).
- **Pacotes:** [Homebrew](https://brew.sh/) (veja o [`Brewfile`](./Brewfile)).
- **Shell:** zsh + oh-my-zsh, prompt **Starship**.
- **Editor:** Neovim (veja [`nvim/`](./nvim)).
- **CLIs do dia a dia:** lazygit, lazydocker, fzf, bat, eza, awscli, kubectl, opentofu.

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

### Como ele se mantém seguro (sem vazar segredos)

O truque é que **só arquivos sem segredo são symlinkados e versionados**.
Tudo que carrega identidade ou credenciais é tratado de outro jeito:

| Tipo de arquivo | Estratégia | Versionado? | Exemplos |
|---|---|---|---|
| Config compartilhado, **sem segredo** | **symlink** (`just link`) | ✅ sim | `.zshrc`, `starship.toml`, `nvim/`, `mise/config.toml` |
| Com identidade / segredo | **seed** — copiado **só se faltar** (`just seed`), nunca sobrescreve | ❌ não | `.gitconfig`, `.wakatime.cfg` |
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
