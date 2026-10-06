# Big Bang — bootstrap & maintenance.  Run `just` to list recipes.
# Fresh machine: install Homebrew, then `brew install just`, then `just bootstrap`.

set shell := ["bash", "-euc"]

repo := justfile_directory()
home := env_var('HOME')

# Symlinks (repo -> home), uma lista só, usada por `link` e por `doctor`.
# Formato: <caminho no repo> <caminho na home>, separados por espaço.
links := '''
dotfiles/.zshrc            .zshrc
dotfiles/.gitignore.global .gitignore.global
dotfiles/.opentofurc       .opentofurc
starship/starship.toml     .config/starship.toml
nvim                       .config/nvim
mise/config.toml           .config/mise/config.toml
wezterm/.wezterm.lua       .config/wezterm/wezterm.lua
cmux/ghostty.config        .config/ghostty/config
cmux/cmux.json             .config/cmux/cmux.json
'''

# Versão mínima do cmux com Extensions (beta) e wrapper do Claude (ver cmux/README.md).
# O cask é auto_updates, então o número do brew não reflete o app: `doctor` confere o binário.
cmux_min := "0.64.22"

# Show available recipes
default:
    @just --list

# Full setup on a new machine (idempotent)
bootstrap: brew omz link mise-install seed podman-machine
    @echo ""
    @echo "✅ Bootstrap complete. Open a new terminal (or run: exec zsh)."

# Install oh-my-zsh if missing (the .zshrc expects it; idempotent)
omz:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -d "$HOME/.oh-my-zsh" ]]; then echo "ok     oh-my-zsh already installed"; exit 0; fi
    echo "→ installing oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install/upgrade everything in the Brewfile
brew:
    brew bundle --file="{{ repo }}/Brewfile"

# Install the toolchains pinned in mise/config.toml
mise-install:
    # Trust the repo config so entering the repo dir doesn't error on an untrusted file
    mise trust "{{ repo }}/mise/config.toml"
    mise install

# Init + start the podman VM (macOS needs a Linux VM to run containers; idempotent)
# Sem podman instalado (ex.: máquina pessoal usando docker), pula sem quebrar o bootstrap.
podman-machine:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v podman &>/dev/null; then
      echo "skip   podman não instalado — pulando a VM (usando docker? ok; ver README)"; exit 0
    fi
    if ! podman machine inspect podman-machine-default &>/dev/null; then
      echo "→ creating podman machine"; podman machine init
    fi
    if [[ "$(podman machine inspect podman-machine-default --format '{{{{.State}}' 2>/dev/null)" != "running" ]]; then
      echo "→ starting podman machine"; podman machine start
    else
      echo "ok     podman machine already running"
    fi

# Symlink shared, secret-free configs into place (idempotent; backs up real files)
link:
    #!/usr/bin/env bash
    set -euo pipefail
    printf '%s\n' "{{ links }}" | while read -r src dst; do
      [[ -z "$src" ]] && continue
      just _link "{{ repo }}/$src" "{{ home }}/$dst"
    done

# Seed template files that hold identity/secrets — only if missing (never clobbers)
seed:
    just _seed "{{ repo }}/dotfiles/.zshrc.local.example" "{{ home }}/.zshrc.local"
    just _seed "{{ repo }}/dotfiles/.gitconfig"           "{{ home }}/.gitconfig"
    just _seed "{{ repo }}/dotfiles/.wakatime.cfg"        "{{ home }}/.wakatime.cfg"
    just _seed "{{ repo }}/dotfiles/.aws/config"          "{{ home }}/.aws/config"
    just _seed "{{ repo }}/dotfiles/.npmrc"               "{{ home }}/.npmrc"
    just _seed "{{ repo }}/dotfiles/.clojure/deps.edn"    "{{ home }}/.clojure/deps.edn"
    just _seed_template "{{ repo }}/claude/settings.json" "{{ home }}/.claude/settings.json"
    just _seed "{{ repo }}/claude/usage-budget.example"   "{{ home }}/.claude/usage-budget"
    @echo "→ Now fill identity/keys in ~/.gitconfig, ~/.wakatime.cfg and ~/.zshrc.local"
    @echo "→ Set your monthly token limit (US\$) in ~/.claude/usage-budget"
    @echo "→ GPG: commits são assinados por padrão — crie uma chave (gpg --full-generate-key)"
    @echo "  e preencha user.signingKey, ou rode: git config --global commit.gpgsign false"

# Lista (ou apaga, com `just clean-backups yes`) os `.bak.<timestamp>` que `just link`
# deixa ao lado de cada symlink quando encontra um arquivo real no lugar.
clean-backups confirm="no":
    #!/usr/bin/env bash
    set -euo pipefail
    found=0
    while read -r src dst; do
      [[ -z "$src" ]] && continue
      for b in "{{ home }}/$dst".bak.*; do
        [[ -e "$b" ]] || continue
        found=1
        if [[ "{{ confirm }}" == "yes" ]]; then rm -rf "$b"; echo "rm     $b"; else echo "found  $b"; fi
      done
    done < <(printf '%s\n' "{{ links }}")
    if [[ $found -eq 0 ]]; then echo "ok     no .bak files next to the symlinks"
    elif [[ "{{ confirm }}" != "yes" ]]; then echo "→ Para apagar: just clean-backups yes"; fi

# Update the Brewfile from what's currently installed.
# ⚠️ Sobrescreve o Brewfile CURADO (comentários e seções são perdidos) pelo dump
# cru do brew — revise o `git diff Brewfile` e restaure a organização antes de commitar.
brew-dump:
    brew bundle dump --force --file="{{ repo }}/Brewfile"
    @echo "⚠️  Brewfile sobrescrito pelo dump cru — revise o diff antes de commitar (comentários/seções se perdem)"

# Sanity check: tools, symlinks, git identity/GPG, Brewfile, cmux (exit 1 on any failure)
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    fail=0
    echo "## tools"
    for t in brew mise nvim starship fzf git just podman gh jq gpg git-lfs; do
      if p="$(command -v "$t")"; then printf "  %-10s %s\n" "$t" "$p"; else printf "  %-10s MISSING\n" "$t"; fail=1; fi
    done
    echo "## podman"
    printf "  machine    %s\n" "$(podman machine inspect podman-machine-default --format '{{{{.State}}' 2>/dev/null || echo 'NOT INITIALIZED (run: just podman-machine)')"
    echo "## symlinks"
    while read -r src dst; do
      [[ -z "$src" ]] && continue
      f="{{ home }}/$dst"
      if [[ -L "$f" ]]; then echo "  ok   $f -> $(readlink "$f")"; else echo "  NOT A SYMLINK: $f (run: just link)"; fail=1; fi
    done < <(printf '%s\n' "{{ links }}")
    echo "## git"
    # Identidade: ~/.gitconfig é seedado com os campos vazios — e já foi recriado
    # vazio por ferramenta externa sem ninguém notar. Sem isso o commit falha.
    for k in user.name user.email; do
      v="$(git config --global --get "$k" 2>/dev/null || true)"
      if [[ -n "$v" ]]; then printf "  %-14s %s\n" "$k" "$v"; else printf "  %-14s EMPTY (fill ~/.gitconfig)\n" "$k"; fail=1; fi
    done
    # Assinatura fica ligada de propósito: a chave TEM de existir nesta máquina.
    if [[ "$(git config --global --get commit.gpgsign 2>/dev/null || true)" == "true" ]]; then
      key="$(git config --global --get user.signingKey 2>/dev/null || true)"
      if [[ -z "$key" ]]; then
        printf "  %-14s %s\\n" gpgsign "on, but user.signingKey EMPTY (gpg --full-generate-key, then fill ~/.gitconfig)"; fail=1
      elif gpg --list-secret-keys "$key" >/dev/null 2>&1; then
        printf "  %-14s %s\\n" gpgsign "on, key $key present"
      else
        printf "  %-14s %s\\n" gpgsign "on, but key $key NOT FOUND in gpg (import it or generate a new one)"; fail=1
      fi
    else
      printf "  %-14s %s\\n" gpgsign "off (repo default is on — see dotfiles/.gitconfig)"
    fi
    echo "## brew"
    if brew bundle check --file="{{ repo }}/Brewfile" >/dev/null 2>&1; then
      echo "  ok   Brewfile satisfied"
    else
      echo "  DIVERGENT from Brewfile (run: just brew). Missing:"
      brew bundle check --verbose --file="{{ repo }}/Brewfile" 2>&1 | grep '^→' | sed 's/^→/   /'
      fail=1
    fi
    echo "## cmux"
    if command -v cmux >/dev/null 2>&1; then
      v="$(cmux --version 2>/dev/null | awk '{print $2}')"
      if [[ "$(printf '%s\n%s\n' "{{ cmux_min }}" "$v" | sort -V | head -1)" == "{{ cmux_min }}" ]]; then
        echo "  ok   cmux $v (min {{ cmux_min }})"
      else
        echo "  cmux $v is OLDER than {{ cmux_min }} (update the app: Extensions beta / Claude resume need it)"; fail=1
      fi
      if [[ "$(defaults read com.cmuxterm.app extensions.beta.enabled 2>/dev/null || echo 0)" == "1" ]]; then
        echo "  ok   Extensions (beta) enabled — plugins button"
      else
        echo "  Extensions (beta) OFF — no plugins button (Settings > enable; see cmux/README.md)"
      fi
    else
      echo "  skip cmux not installed (it's in the Brewfile)"
    fi
    exit $fail

# Open a PR for the current branch in the browser (requires: gh auth login)
pr:
    gh pr create --web --fill

# Standalone (not in `bootstrap`): depends on the `claude` CLI, which this repo
# doesn't manage. Idempotent; user scope, so it applies to every project.
# Install the ruflo Claude Code plugin — multi-agent orchestration (slash commands)
ruflo:
    claude plugin marketplace add ruvnet/ruflo
    claude plugin install ruflo-core@ruflo --scope user
    @echo "→ ruflo-core installed (user scope). New skills/agents load next Claude Code session."

# cmux: settings que só existem na UI (UserDefaults) e não têm chave no cmux.json —
# hoje, o beta "Extensions" (botão de plugins na sidebar). Idempotente. Ver cmux/README.md.
cmux-settings:
    #!/usr/bin/env bash
    set -euo pipefail
    defaults write com.cmuxterm.app extensions.beta.enabled -bool true
    echo "ok     cmux: Extensions (beta) ligado (extensions.beta.enabled=1)"
    echo "→ Reabra o cmux (Cmd+Q e abrir de novo) pra aplicar."

# --- internal helpers (hidden from --list) ---

# Symlink src -> dst, backing up an existing real file
_link src dst:
    #!/usr/bin/env bash
    set -euo pipefail
    src="{{ src }}"; dst="{{ dst }}"
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then echo "ok     $dst"; exit 0; fi
    if [[ -e "$dst" && ! -L "$dst" ]]; then
      bak="$dst.bak.$(date +%Y%m%d%H%M%S)"; mv "$dst" "$bak"; echo "backup $dst -> $bak"
    fi
    ln -sfn "$src" "$dst"; echo "link   $dst -> $src"

# Copy src -> dst only if dst does not exist (never clobbers secrets)
_seed src dst:
    #!/usr/bin/env bash
    set -euo pipefail
    src="{{ src }}"; dst="{{ dst }}"
    if [[ -e "$dst" ]]; then echo "keep   $dst (already exists)"; exit 0; fi
    mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"
    # Arquivos seedados recebem identidade/tokens — nascem legíveis só pelo dono
    chmod 600 "$dst"; echo "seed   $dst"

# Como _seed, mas substitui __REPO__ pelo caminho real deste clone — assim o
# template funciona em qualquer fork/diretório, sem caminho fixo do autor
_seed_template src dst:
    #!/usr/bin/env bash
    set -euo pipefail
    src="{{ src }}"; dst="{{ dst }}"
    if [[ -e "$dst" ]]; then echo "keep   $dst (already exists)"; exit 0; fi
    mkdir -p "$(dirname "$dst")"
    sed "s|__REPO__|{{ repo }}|g" "$src" >"$dst"
    chmod 600 "$dst"; echo "seed   $dst"
