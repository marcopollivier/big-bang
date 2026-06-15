# Big Bang

<!--
Badges generator https://badgesgenerator.com/
Simple Icons https://simpleicons.org/?q=ubuntu
-->

![macOS](https://img.shields.io/badge/macOS-first-green?labelColor=gray&style=flat&logo=apple&logoColor=white)

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

> 🌐 **🇧🇷 Português** · [🇺🇸 English](./README-en.md)

## Motivação

O projeto **Big Bang** é a minha fonte única de verdade para a configuração da
máquina: dotfiles, editor, terminal e prompt. O objetivo é **conveniência** —
quando configuro uma máquina nova ou reinstalo uma ferramenta, venho aqui pra
lembrar como o meu ambiente está montado e colocar os configs de volta no lugar.

> Um repositório de referência / dotfiles curado. O setup é roteirizado com
> [`just`](https://github.com/casey/just) (sem framework pesado de provisionamento).

## Público-alvo

Este projeto foi pensado pra todo mundo. Seja pra uso pessoal ou profissional,
fique à vontade pra fazer um fork e adaptar como precisar.

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

## Setup (máquina nova)

1. Instale o [Homebrew](https://brew.sh/) e, em seguida, o `just`:
   ```sh
   brew install just
   ```
2. Clone o repo e rode o bootstrap:
   ```sh
   git clone git@github.com:marcopollivier/big-bang.git && cd big-bang
   just bootstrap
   ```

O `just bootstrap` é **idempotente** e executa:

- `just brew` — instala tudo que está no [`Brewfile`](./Brewfile)
- `just link` — cria os symlinks dos configs compartilhados (zsh, starship, nvim, mise…); arquivos reais existentes têm backup feito antes
- `just mise-install` — instala os toolchains do [`mise/config.toml`](./mise/config.toml)
- `just seed` — copia os templates de segredo/identidade (`.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`) **só se não existirem**

Depois, preencha sua identidade/chaves: nome/e-mail do git, chave do WakaTime e os segredos em `~/.zshrc.local`.

### Manutenção

```sh
just            # lista todas as recipes
just link       # reaplica os symlinks
just brew       # instala/atualiza os pacotes do Brewfile
just brew-dump  # atualiza o Brewfile a partir do que está instalado
just doctor     # checa ferramentas + symlinks
just ruflo      # instala o plugin ruflo do Claude Code (precisa da CLI `claude`)
```

## Como funcionam os symlinks

Os configs deste repo **não são copiados** para a sua home — eles são
**symlinkados**. Um symlink é um ponteiro: o arquivo na sua home (ex.: `~/.zshrc`)
é só um atalho para o arquivo real dentro do repo
(`big-bang/dotfiles/.zshrc`). Existe apenas **um** arquivo real.

```
~/.zshrc  ──▶  ~/dev/mpo/big-bang/dotfiles/.zshrc   (o arquivo real, versionado)
```

O `just link` cria esses links (veja o [`justfile`](./justfile)). Ele é
**idempotente** — links já corretos são deixados intactos e, se um arquivo
*real* já estiver no lugar, é feito um backup em `<arquivo>.bak.<timestamp>`
antes de o link substituí-lo, então nada nunca é perdido.

### É automático

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

## Segredos

**Nenhuma credencial é versionada.** Valores específicos da máquina e segredos
(`AWS_*`, `GITHUB_TOKEN`, ARNs dos clusters EKS, chave de API do WakaTime, …)
ficam em `~/.zshrc.local`, que é git-ignored. Use o
[`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example) como template.

## Qualidade

- **CI** ([`ci.yml`](./.github/workflows/ci.yml)): sintaxe do zsh, formatação Lua
  (stylua), validação do justfile e scan de segredos (gitleaks) em todo push/PR.
- **Hooks locais** ([`.pre-commit-config.yaml`](./.pre-commit-config.yaml)):
  `brew install pre-commit && pre-commit install`.
- **Formatação:** [`.editorconfig`](./.editorconfig) + [`.stylua.toml`](./.stylua.toml).

## Licença

Este projeto é licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.
