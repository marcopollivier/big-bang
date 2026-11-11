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

From a blank Mac to a ready environment, copy-pasting top to bottom (first
time? read [Prerequisites](#prerequisites) and
[Fork it](#fork-it-make-it-yours) first):

```sh
# 0. Xcode Command Line Tools (git, compilers) — opens a dialog; wait for it to finish
xcode-select --install

# 1. Homebrew + PATH for this session (Intel: /usr/local/bin/brew)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. just
brew install just

# 3. clone via HTTPS (no SSH key needed yet) + bootstrap (idempotent)
git clone https://github.com/marcopollivier/big-bang.git ~/dev/marcopollivier/big-bang
cd ~/dev/marcopollivier/big-bang
just report      # optional: what's already there, what's missing, what will conflict
just bootstrap

# 4. new terminal → GitHub login (creates/uploads the SSH key) → validate
exec zsh
gh auth login --git-protocol ssh --web
git remote set-url origin git@github.com:marcopollivier/big-bang.git
just doctor
```

After that, fill in identity/secrets and the GPG key — step 3 of the
[Step-by-step setup](#step-by-step-setup).

## Prerequisites

What needs to exist **before** the bootstrap — not much:

- **macOS** (Apple Silicon or Intel), with an **administrator** user (the
  Homebrew installer asks for `sudo`). The project is *macOS-first*.
- **Xcode Command Line Tools** — they bring `git` and the compilers Homebrew
  uses. The command opens a system dialog; wait for the install to finish:
  ```sh
  xcode-select --install
  ```
- **[Homebrew](https://brew.sh/)** — install it with the official one-liner and
  put it on the current session's PATH (the installer prints this at the end):
  ```sh
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"   # Intel: eval "$(/usr/local/bin/brew shellenv)"
  ```
  No need to edit `~/.zprofile`: the repo's [`.zshrc`](./dotfiles/.zshrc)
  makes it permanent after `just link`.
- **A GitHub account.** An **SSH key is _not_ a prerequisite:** on a new
  machine, clone via **HTTPS** (no auth needed for a public repo). After the
  bootstrap, `gh` (shipped in the [`Brewfile`](./Brewfile)) creates and
  registers the SSH key for you — see step 4 of the [Step-by-step setup](#step-by-step-setup).

Everything else (`gh`, `git-lfs`, `gnupg`, `mise`, oh-my-zsh, toolchains…) is
installed by `just bootstrap`.

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
| **Containers (work vs personal)** | [`Brewfile`](./Brewfile) + bootstrap | at **work**: podman (Docker Desktop has a commercial license); on a **personal machine**: docker is fine — swap `brew "podman"` for the `docker` cask (commented in the Brewfile) and `just podman-machine` skips itself |
| **Editor languages** | [`nvim/`](./nvim) | Neovim ships ready for **Go, .NET/C# and Kotlin**; adapt the LSPs to your stack |
| **Toolchains** | [`mise/config.toml`](./mise/config.toml) | Go/Java/Node/… versions that get installed. Languages only your machine needs (e.g. Clojure, Maven on a personal one) go in `~/.config/mise/conf.d/*.toml`, outside the repo. Coming from asdf? Drop the asdf line from your shell and move `~/.tool-versions` out of your home (mise reads it, and its versions override the repo's) |
| **Clone path** | nothing, if you use `just seed`/`just link` | the Claude statusline ([`claude/settings.json`](./claude/settings.json)) and the WezTerm status discover the clone by themselves (fallback: the `~/dev/<github-user>/big-bang` convention); if something fails, set `BIG_BANG_REPO` in `~/.zshrc.local` |
| **npm token** | `~/.npmrc` (after `just seed`) | the template ([`dotfiles/.npmrc`](./dotfiles/.npmrc)) reads `NPM_TOKEN` from the environment — set it in `~/.zshrc.local` if you use a private registry |

> 💡 **Golden rule:** files with identity/secrets are only *copied* (`just seed`)
> and **never** overwritten nor committed back — so you can edit them freely in
> your home. Details in [How it works under the hood](#how-it-works-under-the-hood).

## Step-by-step setup

**1. Install the [Prerequisites](#prerequisites) (Xcode Command Line Tools
and Homebrew), then `just`:**

```sh
brew install just
```

**2. Clone your fork (via HTTPS) and bootstrap:**

```sh
git clone https://github.com/<you>/big-bang.git ~/dev/<you>/big-bang
cd ~/dev/<you>/big-bang
just report      # before: what the bootstrap will do on this machine
just bootstrap
```

> 🔎 **Before running the bootstrap**, `just report` shows the machine inventory:
> every Brewfile item, mise toolchain, symlink and seed with a status (`ok`,
> `missing` = will be installed, `conflict` = already exists outside brew — e.g.
> a manually installed app, fix with `brew install --cask --adopt <cask>`),
> version and **where it came from**; plus what's installed outside the repo
> (extra brew packages, manual/App Store apps, `/usr/local/bin`, `npm -g`). The
> report is saved under `~/.big-bang/reports/` (`latest.md` is the newest) and
> the bootstrap writes a new one at the end — compare them with `diff`.
> `~/.big-bang/` is **machine** state and never goes into the repo.

> 📁 **Folder convention:** projects live in `~/dev/<owner>/<project>` — the
> owner is the GitHub user/org (e.g. `~/dev/<you>/big-bang`). Only dotfiles go
> in the home root (`~/`), via symlink/seed. It's not mandatory (everything is
> auto-discovered, and `BIG_BANG_REPO` covers exceptions), but it's the pattern
> the repo assumes as a fallback.

`just bootstrap` is **idempotent** (run it as many times as you like) and runs:

- `just brew` — install everything in the [`Brewfile`](./Brewfile)
- `just omz` — install oh-my-zsh if missing (the `.zshrc` depends on it)
- `just link` — symlink the shared configs (zsh, starship, nvim, mise…); existing real files are backed up first
- `just mise-install` — install the toolchains from [`mise/config.toml`](./mise/config.toml)
- `just seed` — copy secret/identity templates **only if missing**: `.gitconfig`, `.wakatime.cfg`, `~/.zshrc.local`, `~/.npmrc`, `~/.aws/config`, `~/.clojure/deps.edn` and the Claude Code ones (`~/.claude/settings.json`, `~/.claude/usage-budget` and `~/.claude/automode.local.json` — see [`claude/`](./claude))
- `just automode` — write the Claude Code *auto mode* config ([`claude/automode.json`](./claude/automode.json)) into `~/.claude/settings.json`
- `just gpg-agent` — point `gpg-agent` at `pinentry-mac` (GPG key passphrase in a macOS dialog, with the option to store it in the Keychain)
- `just podman-machine` — create/start the podman Linux VM (on macOS containers run inside it)
- `just report` — save the post-bootstrap inventory under `~/.big-bang/reports/`

**3. Fill in your identity and secrets** (see the table in
[Fork it](#fork-it-make-it-yours)): git name/email in `~/.gitconfig`, WakaTime
key in `~/.wakatime.cfg`, and the secrets in `~/.zshrc.local`.

> 🔑 **GPG key — don't skip this step.** The `.gitconfig` ships with commit
> signing **enabled** (`commit.gpgSign = true`); without a configured key,
> every `git commit` fails. Create yours:
>
> ```sh
> gpg --full-generate-key                        # answers below
> gpg --list-secret-keys --keyid-format=long     # copy the ID after "sec ed25519/"
> git config --global user.signingkey <ID>
> gpg --armor --export <ID>                      # paste into GitHub → Settings → SSH and GPG keys
> ```
>
> Answers for `gpg --full-generate-key`:
>
> | Question | Answer | Why |
> |---|---|---|
> | Key type | **`9` — ECC (sign and encrypt)**, the default | Creates ed25519 (signing) + cv25519 (encryption): short, fast and accepted by GitHub. Avoid `16` (ECC and Kyber, post-quantum): GitHub doesn't accept it yet. `1`/`4` (RSA 4096) also work, they're just slower and bigger. |
> | Curve | **`1` — Curve 25519**, the default | The recommended one; NIST/Brainpool only if compliance requires it. |
> | Expiration | **`2y`** (or `0` = never expires) | Expiring limits the damage if the key leaks. Renewing is one command (`gpg --quick-set-expire <ID> 2y`) plus re-uploading the public key to GitHub; old commits stay verified. |
> | Name and e-mail | **The same as in `~/.gitconfig`** | GitHub only shows *Verified* if the key's e-mail is a **verified e-mail on your account**. |
> | Comment | empty | — |
> | Passphrase | a strong one | See below: you won't type it on every commit. |
>
> **You won't be asked for the passphrase on every commit.** It's only used to
> *sign*, and `just gpg-agent` (already part of `bootstrap`) sets up
> `pinentry-mac`: the first signature opens a macOS dialog — tick **"Save in
> Keychain"** and it's unlocked automatically while you're logged in. Without the
> Keychain, `gpg-agent` still caches it for a few minutes.
>
> Don't want signed commits? Turn it off for good:
> `git config --global commit.gpgsign false`

**4. Authenticate with GitHub and set up the SSH key** (used for clone/push —
not to be confused with the GPG key above, which only signs commits):

```sh
gh auth login --git-protocol ssh --web   # if there's no key, gh generates one and registers it on GitHub
git remote set-url origin git@github.com:<you>/big-bang.git   # switch the HTTPS clone to SSH
ssh -T git@github.com                    # should answer "Hi <you>! …"
```

<details>
<summary>Prefer to create the SSH key by hand?</summary>

```sh
ssh-keygen -t ed25519 -C "<your-email>"  # accept the default path (~/.ssh/id_ed25519)
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get ComputerName)"
# or paste the .pub contents into GitHub → Settings → SSH and GPG keys
```

</details>

**5. Open a new terminal** (or `exec zsh`) and **validate** everything is in place:

```sh
just doctor   # checks tools, symlinks, git identity + GPG key, Brewfile, cmux and the podman VM
```

> 🏢 On a **managed Mac** (MDM) or **behind a corporate proxy (Zscaler)**, some
> steps need tweaks — see [Troubleshooting / FAQ](#troubleshooting--faq).

## Day-to-day commands

Run `just` (no arguments) to list all recipes. The most-used ones:

| Command | What it does |
|---|---|
| `just` | list all available recipes |
| `just bootstrap` | full new-machine setup (idempotent) |
| `just doctor` | checks tools, symlinks, git identity + GPG key, Brewfile drift, Claude Code config (auto mode + statusline), cmux version and the podman VM |
| `just report` | machine inventory (status, version and origin of each item; conflicts with manually installed things) under `~/.big-bang/reports/` |
| `just link` | re-apply symlinks (run after adding a new config) |
| `just brew` | install/upgrade the [`Brewfile`](./Brewfile) packages |
| `just brew-dump` | update the `Brewfile` from what's installed |
| `just clean-backups` | list the `.bak.*` files left by `just link` (delete with `just clean-backups yes`) |
| `just mise-install` | install the toolchains from [`mise/config.toml`](./mise/config.toml) |
| `just seed` | copy the identity/secret templates (only if missing) |
| `just automode` | re-apply the Claude Code auto mode config (repo + `~/.claude/automode.local.json`) |
| `just cmux-settings` | enable the cmux settings that only live in the UI (Extensions beta = plugins button) |
| `just gpg-agent` | set `pinentry-mac` in `~/.gnupg/gpg-agent.conf` (only if no other pinentry is set) |
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
| [`claude/`](./claude) | [Claude Code](https://claude.com/claude-code) config + token-usage tracking (statusline and month status in WezTerm). See its [`README`](./claude/README.md). |
| [`cmux/`](./cmux) | AI agent orchestrator (embedded Ghostty terminal), being tried as a WezTerm alternative. See its [`README`](./cmux/README.md). |
| [`defaultdots/`](./defaultdots) | Pristine/original dotfiles, kept as a reset reference. |
| [`scripts/`](./scripts) | Larger scripts called by the `justfile` — e.g. `report.sh` (`just report`). |

Each folder has its own `README.md`. Root files worth knowing:

- [`justfile`](./justfile) — bootstrap & maintenance commands (`just`).
- [`Brewfile`](./Brewfile) — Homebrew packages (`brew bundle`).
- [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) — local quality/secret hooks.
- [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) — CI (lint, syntax, secret scan).
- `.claude/` — slash commands for Claude Code users in this repo:
  **`/setup-machine`** (guided from-scratch machine setup) and **`/sync`**
  (re-syncs symlinks/Brewfile and reports drift).

## Tooling / stack

- **Version manager:** [mise](https://mise.jdx.dev/) — Go, Java, Kotlin, Node,
  .NET… (replaced asdf/nvm/pyenv). See [`mise/config.toml`](./mise/config.toml).
- **Packages:** [Homebrew](https://brew.sh/) (see [`Brewfile`](./Brewfile)).
- **Shell:** zsh + oh-my-zsh, **Starship** prompt.
- **Editor:** Neovim (see [`nvim/`](./nvim)).
- **Day-to-day CLIs:** lazygit, lazydocker, fzf, bat, eza, awscli, kubectl, argocd, opentofu.

## How it works under the hood

You don't need this section to use the project — it explains *why* the setup is
safe and why editing from either side "just works".

### Symlinks

The configs in this repo are **not copied** to your home directory — they are
**symlinked**. A symlink is a pointer: the file in your home (e.g. `~/.zshrc`)
is just a shortcut to the real file inside the repo
(`big-bang/dotfiles/.zshrc`). There is only **one** real file.

```
~/.zshrc  ──▶  ~/<your-dir>/big-bang/dotfiles/.zshrc   (the real file, versioned)
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

> ⚠️ **Symlink side effect:** installers that do `>> ~/.zshrc` (many CLIs do)
> write **straight into the repo's versioned file**. Before committing, check
> `git diff` — move anything machine-specific to `~/.zshrc.local` instead of
> leaving it in the repo's `.zshrc`.

### How it stays safe (no secret leaks)

The trick is that **only secret-free files are symlinked and committed**.
Anything that carries identity or credentials is handled differently:

| Kind of file | Strategy | Committed? | Examples |
|---|---|---|---|
| Shared, **secret-free** config | **symlink** (`just link`) | ✅ yes | `.zshrc`, `starship.toml`, `nvim/`, `mise/config.toml` |
| Identity / secret-bearing | **seed** — copied **only if missing** (`just seed`), never overwritten | ❌ no | `.gitconfig`, `.wakatime.cfg`, `.npmrc` |
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
