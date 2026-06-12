# Big Bang

<!--
Badges generator https://badgesgenerator.com/
Simple Icons https://simpleicons.org/?q=ubuntu
-->

![macOS](https://img.shields.io/badge/macOS-first-green?labelColor=gray&style=flat&logo=apple&logoColor=white)

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

## Motivation

The **Big Bang** project is my single source of truth for machine configuration:
dotfiles, editor, terminal and prompt. The goal is **convenience** — when I set
up a new machine or reinstall a tool, I come here to remember how my environment
is put together and to put the configs back into place.

> A curated reference / dotfiles repository. Setup is scripted with
> [`just`](https://github.com/casey/just) (no heavy provisioning framework).

## Target Audience

This project is designed for everyone. Whether for personal or professional use,
you are welcome to fork and adapt it as needed.

## Repository structure

| Folder | What lives here |
|---|---|
| [`dotfiles/`](./dotfiles) | Home dotfiles (`.zshrc`, `.gitconfig`, `.wakatime.cfg`, AWS/Clojure/OpenTofu configs…). Templates with **no secrets** committed. |
| [`nvim/`](./nvim) | Neovim as an IDE for **Go, .NET/C# and Kotlin** (lazy.nvim, LSP via Mason, Claude Code + WakaTime). See its [`SETUP.md`](./nvim/SETUP.md). |
| [`wezterm/`](./wezterm) | [WezTerm](https://wezfurlong.org/wezterm/) terminal configuration. |
| [`starship/`](./starship) | [Starship](https://starship.rs/) shell prompt configuration. |
| [`mise/`](./mise) | Global [mise](https://mise.jdx.dev/) config — toolchain versions. |
| [`defaultdots/`](./defaultdots) | Pristine/original dotfiles, kept as a reset reference. |

Each folder has its own `README.md`. Root files worth knowing:

- [`justfile`](./justfile) — bootstrap & maintenance commands (`just`).
- [`Brewfile`](./Brewfile) — Homebrew packages (`brew bundle`).
- [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) — local quality/secret hooks.
- [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) — CI (lint, syntax, secret scan).

## Tooling / stack

- **Version manager:** [mise](https://mise.jdx.dev/) — Go, Java, Kotlin, Node,
  .NET, Python… (replaced asdf/nvm/pyenv).
- **Packages:** [Homebrew](https://brew.sh/) (see [`Brewfile`](./Brewfile)).
- **Shell:** zsh + oh-my-zsh, **Starship** prompt.
- **Editor:** Neovim (see [`nvim/`](./nvim)).
- **Day-to-day CLIs:** lazygit, lazydocker, fzf, bat, eza, awscli, kubectl, opentofu.

## Setup (new machine)

1. Install [Homebrew](https://brew.sh/), then `just`:
   ```sh
   brew install just
   ```
2. Clone the repo and bootstrap:
   ```sh
   git clone git@github.com:marcopollivier/big-bang.git && cd big-bang
   just bootstrap
   ```

`just bootstrap` is **idempotent** and runs:

- `just brew` — install everything in the [`Brewfile`](./Brewfile)
- `just link` — symlink the shared configs (zsh, starship, nvim, mise…); existing real files are backed up first
- `just mise-install` — install the toolchains from [`mise/config.toml`](./mise/config.toml)
- `just seed` — copy secret/identity templates (`.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`) **only if missing**

Then fill in your identity/keys: git name/email, WakaTime key, and the secrets in `~/.zshrc.local`.

### Maintenance

```sh
just            # list all recipes
just link       # re-apply symlinks
just brew       # install/upgrade Brewfile packages
just brew-dump  # update the Brewfile from what's installed
just doctor     # check tools + symlinks
```

## Secrets

**No credentials are committed.** Machine-specific values and secrets
(`AWS_*`, `GITHUB_TOKEN`, EKS cluster ARNs, WakaTime API key, …) live in
`~/.zshrc.local`, which is git-ignored. Use
[`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example) as a template.

## Quality

- **CI** ([`ci.yml`](./.github/workflows/ci.yml)): zsh syntax, Lua formatting
  (stylua), justfile validation, and secret scanning (gitleaks) on every push/PR.
- **Local hooks** ([`.pre-commit-config.yaml`](./.pre-commit-config.yaml)):
  `brew install pre-commit && pre-commit install`.
- **Formatting:** [`.editorconfig`](./.editorconfig) + [`.stylua.toml`](./.stylua.toml).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
