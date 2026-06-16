# Big Bang

<!--
Badges generator https://badgesgenerator.com/
Simple Icons https://simpleicons.org/?q=ubuntu
-->

![macOS](https://img.shields.io/badge/macOS-first-green?labelColor=gray&style=flat&logo=apple&logoColor=white)

![Big Bang Cover](https://p2.trrsf.com/image/fget/cf/460/0/images.terra.com/2018/03/06/o-que-existia-antes-do-big-bang-stephen-hawking-responde.jpg "Big Bang Project Cover")

> 🌐 [🇧🇷 Português](./README.md) (main) · **🇺🇸 English**

Versioned, scripted machine configuration (macOS): **dotfiles, editor, terminal
and prompt** you install on a fresh machine with a few commands. Fork it, tweak
what's yours, and run `just bootstrap`.

## Table of contents

- [What is this](#what-is-this)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Fork it (make it yours)](#fork-it-make-it-yours)
- [Step-by-step setup](#step-by-step-setup)
- [Day-to-day commands](#day-to-day-commands)
- [Repository structure](#repository-structure)
- [Tooling / stack](#tooling--stack)
- [How it works under the hood](#how-it-works-under-the-hood)
- [Troubleshooting / FAQ](#troubleshooting--faq)
- [Quality](#quality)
- [License](#license)

## What is this

The **Big Bang** project is my single source of truth for machine configuration:
dotfiles, editor, terminal and prompt. The goal is **convenience** — when I set
up a new machine or reinstall a tool, I come here to remember how my environment
is put together and to put the configs back into place.

> A curated reference / dotfiles repository. Setup is scripted with
> [`just`](https://github.com/casey/just) (no heavy provisioning framework).

**Is it for you?** It's designed for everyone. Whether for personal or
professional use, you are welcome to fork and adapt it. Note it's an
**opinionated** setup (my git, my keys, my Neovim languages) — so the right flow
is to fork and [make it yours](#fork-it-make-it-yours) before running it.

## Quick Start

For those who already know what they're doing (first time? jump to
[Fork it](#fork-it-make-it-yours) first):

```sh
# 1. Homebrew (if you don't have it) → https://brew.sh
# 2. just
brew install just

# 3. clone + bootstrap (idempotent)
git clone git@github.com:marcopollivier/big-bang.git && cd big-bang
just bootstrap

# 4. fill in identity/secrets and validate
just doctor
```

## Prerequisites

- **macOS** (Apple Silicon or Intel). The project is *macOS-first*.
- **Xcode Command Line Tools** — required for git and Homebrew:
  ```sh
  xcode-select --install
  ```
- **[Homebrew](https://brew.sh/)** installed (`just bootstrap` handles the rest
  of the packages from the [`Brewfile`](./Brewfile)).
- An SSH key on GitHub (to clone via `git@github.com:…`) or use the HTTPS URL.

## Fork it (make it yours)

This repo carries **my** identity and choices. Before running the bootstrap on
your own machine, **fork** it and adjust what's personal. Nothing here has
committed secrets — only *templates* — but several defaults are mine:

| What to change | Where | Why |
|---|---|---|
| **Clone URL** | replace `marcopollivier/big-bang` with your fork | point at *your* repository |
| **Git identity** | `~/.gitconfig` (after `just seed`) — `name`, `email`, `signingKey` | the template ([`dotfiles/.gitconfig`](./dotfiles/.gitconfig)) ships blank |
| **Machine secrets** | `~/.zshrc.local` (after `just seed`) | `AWS_*`, `GITHUB_TOKEN`, EKS ARNs, WakaTime key — see [`.zshrc.local.example`](./dotfiles/.zshrc.local.example) |
| **WakaTime** | `~/.wakatime.cfg` | your API key (optional; remove if unused) |
| **Packages** | [`Brewfile`](./Brewfile) | add/remove apps and CLIs to taste |
| **Editor languages** | [`nvim/`](./nvim) | Neovim ships ready for **Go, .NET/C# and Kotlin**; adapt the LSPs to your stack |
| **Toolchains** | [`mise/config.toml`](./mise/config.toml) | Go/Java/Node/… versions that get installed |

> 💡 **Golden rule:** files with identity/secrets are only *copied* (`just seed`)
> and **never** overwritten nor committed back — so you can edit them freely in
> your home. Details in [How it works under the hood](#how-it-works-under-the-hood).

## Step-by-step setup

**1. Install [Homebrew](https://brew.sh/), then `just`:**

```sh
brew install just
```

**2. Clone your fork and bootstrap:**

```sh
git clone git@github.com:<you>/big-bang.git && cd big-bang
just bootstrap
```

`just bootstrap` is **idempotent** (run it as many times as you like) and runs:

- `just brew` — install everything in the [`Brewfile`](./Brewfile)
- `just link` — symlink the shared configs (zsh, starship, nvim, mise…); existing real files are backed up first
- `just mise-install` — install the toolchains from [`mise/config.toml`](./mise/config.toml)
- `just seed` — copy secret/identity templates (`.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`) **only if missing**
- `just podman-machine` — create/start the podman Linux VM (on macOS containers run inside it)

**3. Fill in your identity and secrets** (see the table in
[Fork it](#fork-it-make-it-yours)): git name/email in `~/.gitconfig`, WakaTime
key in `~/.wakatime.cfg`, and the secrets in `~/.zshrc.local`.

**4. Open a new terminal** (or `exec zsh`) and **validate** everything is in place:

```sh
just doctor   # checks tools + symlinks + the podman VM
```

> 🏢 On a **managed Mac** (MDM) or **behind a corporate proxy (Zscaler)**, some
> steps need tweaks — see [Troubleshooting / FAQ](#troubleshooting--faq).

## Day-to-day commands

Run `just` (no arguments) to list all recipes. The most-used ones:

| Command | What it does |
|---|---|
| `just` | list all available recipes |
| `just bootstrap` | full new-machine setup (idempotent) |
| `just doctor` | check tools, symlinks and the podman VM |
| `just link` | re-apply symlinks (run after adding a new config) |
| `just brew` | install/upgrade the [`Brewfile`](./Brewfile) packages |
| `just brew-dump` | update the `Brewfile` from what's installed |
| `just mise-install` | install the toolchains from [`mise/config.toml`](./mise/config.toml) |
| `just seed` | copy the identity/secret templates (only if missing) |
| `just podman-machine` | create/start the podman Linux VM |
| `just pr` | open a PR for the current branch in the browser (needs `gh auth login`) |
| `just ruflo` | install the ruflo Claude Code plugin (needs the `claude` CLI) |

> ⚠️ **Don't push directly to `main`.** Work on a branch and open a PR with `just pr`.

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

## How it works under the hood

You don't need this section to use the project — it explains *why* the setup is
safe and why editing from either side "just works".

### Symlinks

The configs in this repo are **not copied** to your home directory — they are
**symlinked**. A symlink is a pointer: the file in your home (e.g. `~/.zshrc`)
is just a shortcut to the real file inside the repo
(`big-bang/dotfiles/.zshrc`). There is only **one** real file.

```
~/.zshrc  ──▶  ~/dev/mpo/big-bang/dotfiles/.zshrc   (the real file, versioned)
```

`just link` creates these links (see [`justfile`](./justfile)). It is
**idempotent** — already-correct links are left untouched, and if a *real*
file is already in place it is backed up to `<file>.bak.<timestamp>` before the
link replaces it, so nothing is ever lost.

#### It's automatic

Because home and repo point to the same file, **editing on either side updates
both at once** — there is no sync step:

- Edit `~/.config/nvim/init.lua` → the repo sees the change, ready to commit.
- `git pull` a change from another machine → it's already live in your home.

To re-apply or repair the links after adding a new config, just run `just link`
again.

### How it stays safe (no secret leaks)

The trick is that **only secret-free files are symlinked and committed**.
Anything that carries identity or credentials is handled differently:

| Kind of file | Strategy | Committed? | Examples |
|---|---|---|---|
| Shared, **secret-free** config | **symlink** (`just link`) | ✅ yes | `.zshrc`, `starship.toml`, `nvim/`, `mise/config.toml` |
| Identity / secret-bearing | **seed** — copied **only if missing** (`just seed`), never overwritten | ❌ no | `.gitconfig`, `.wakatime.cfg` |
| Pure secrets / machine-specific | kept in a **git-ignored** file you fill in by hand | ❌ no | `~/.zshrc.local` |

So the layered protection is:

1. **No secrets in the symlinked templates.** Committed configs read their
   secrets from the environment (e.g. `~/.zshrc` does
   `[ -f ~/.zshrc.local ] && source ~/.zshrc.local`) instead of hard-coding them.
2. **`just seed` never clobbers.** Files that hold identity are *copied* once and
   then ignored — your real `~/.gitconfig` is never linked back into the repo,
   so it can't be committed by accident.
3. **`~/.zshrc.local` is git-ignored** and never leaves your machine. Start from
   [`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example).
4. **Defense in depth:** [gitleaks](./.github/workflows/ci.yml) runs in CI and
   the [pre-commit hooks](./.pre-commit-config.yaml) scan for secrets, so an
   accidental credential is blocked before it can be pushed.

**Rule of thumb:** if a file contains a secret, it must *not* be symlinked — put
the secret in `~/.zshrc.local` and reference it from a committed template.

### Where the secrets live

**No credentials are committed.** Machine-specific values and secrets
(`AWS_*`, `GITHUB_TOKEN`, EKS cluster ARNs, WakaTime API key, …) live in
`~/.zshrc.local`, which is git-ignored. Use
[`dotfiles/.zshrc.local.example`](./dotfiles/.zshrc.local.example) as a template.

## Troubleshooting / FAQ

### `podman pull` fails with `x509: certificate signed by unknown authority`

Happens on a managed machine with **Zscaler** (TLS inspection): the podman VM
doesn't trust the Zscaler CA. The fix is to inject the root CA (already in the
macOS keychain) into the VM trust store:

```sh
# export the Zscaler root CA from the System keychain
security find-certificate -a -c "Zscaler Root CA" -p /Library/Keychains/System.keychain > /tmp/zscaler-root-ca.crt

# copy it into the VM and refresh the trust store
podman machine ssh 'cat > /tmp/zscaler-root-ca.crt' < /tmp/zscaler-root-ca.crt
podman machine ssh 'sudo cp /tmp/zscaler-root-ca.crt /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust'
```

> ⚠️ This is **ephemeral**: if the VM is recreated (`podman machine rm` + `init`), repeat the step.

### Tools that talk to the default Docker socket (testcontainers, etc.)

Install the helper once:

```sh
sudo $(brew --prefix)/bin/podman-mac-helper install && podman machine stop && podman machine start
```

### `brew install --cask <app>` asks for a password / fails on a managed Mac

On an **MDM-managed** Mac, `/Applications` is owned by root and your user can't
write there. Installing a GUI app cask falls back to a `sudo cp` and asks for the
password **interactively** — so run it yourself, in a terminal:

```sh
brew install --cask visual-studio-code
```

CLI/font casks (which don't go into `/Applications`) install normally.

## Quality

- **CI** ([`ci.yml`](./.github/workflows/ci.yml)): zsh syntax, Lua formatting
  (stylua), justfile validation, and secret scanning (gitleaks) on every push/PR.
- **Local hooks** ([`.pre-commit-config.yaml`](./.pre-commit-config.yaml)):
  `brew install pre-commit && pre-commit install`.
- **Formatting:** [`.editorconfig`](./.editorconfig) + [`.stylua.toml`](./.stylua.toml).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
</content>
