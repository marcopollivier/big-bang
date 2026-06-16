# Big Bang — bootstrap & maintenance.  Run `just` to list recipes.
# Fresh machine: install Homebrew, then `brew install just`, then `just bootstrap`.

set shell := ["bash", "-uc"]

repo := justfile_directory()
home := env_var('HOME')

# Show available recipes
default:
    @just --list

# Full setup on a new machine (idempotent)
bootstrap: brew link mise-install seed podman-machine
    @echo ""
    @echo "✅ Bootstrap complete. Open a new terminal (or run: exec zsh)."

# Install/upgrade everything in the Brewfile
brew:
    brew bundle --file="{{ repo }}/Brewfile"

# Install the toolchains pinned in mise/config.toml
mise-install:
    # Trust the repo config so entering the repo dir doesn't error on an untrusted file
    mise trust "{{ repo }}/mise/config.toml"
    mise install

# Init + start the podman VM (macOS needs a Linux VM to run containers; idempotent)
podman-machine:
    #!/usr/bin/env bash
    set -euo pipefail
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
    just _link "{{ repo }}/dotfiles/.zshrc"            "{{ home }}/.zshrc"
    just _link "{{ repo }}/dotfiles/.gitignore.global" "{{ home }}/.gitignore.global"
    just _link "{{ repo }}/dotfiles/.opentofurc"       "{{ home }}/.opentofurc"
    just _link "{{ repo }}/starship/starship.toml"     "{{ home }}/.config/starship.toml"
    just _link "{{ repo }}/nvim"                        "{{ home }}/.config/nvim"
    just _link "{{ repo }}/mise/config.toml"           "{{ home }}/.config/mise/config.toml"
    just _link "{{ repo }}/wezterm/.wezterm.lua"       "{{ home }}/.config/wezterm/wezterm.lua"

# Seed template files that hold identity/secrets — only if missing (never clobbers)
seed:
    just _seed "{{ repo }}/dotfiles/.zshrc.local.example" "{{ home }}/.zshrc.local"
    just _seed "{{ repo }}/dotfiles/.gitconfig"           "{{ home }}/.gitconfig"
    just _seed "{{ repo }}/dotfiles/.wakatime.cfg"        "{{ home }}/.wakatime.cfg"
    just _seed "{{ repo }}/dotfiles/.aws/config"          "{{ home }}/.aws/config"
    just _seed "{{ repo }}/dotfiles/.clojure/deps.edn"    "{{ home }}/.clojure/deps.edn"
    just _seed "{{ repo }}/claude/settings.json"          "{{ home }}/.claude/settings.json"
    just _seed "{{ repo }}/claude/usage-budget.example"   "{{ home }}/.claude/usage-budget"
    @echo "→ Now fill identity/keys in ~/.gitconfig, ~/.wakatime.cfg and ~/.zshrc.local"
    @echo "→ Set your monthly token limit (US\$) in ~/.claude/usage-budget"

# Update the Brewfile from what's currently installed
brew-dump:
    brew bundle dump --force --file="{{ repo }}/Brewfile"

# Sanity check: tools present + symlinks resolved
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    echo "## tools"
    for t in brew mise nvim starship fzf git just podman; do
      printf "  %-10s %s\n" "$t" "$(command -v "$t" || echo MISSING)"
    done
    echo "## podman"
    printf "  machine    %s\n" "$(podman machine inspect podman-machine-default --format '{{{{.State}}' 2>/dev/null || echo 'NOT INITIALIZED (run: just podman-machine)')"
    echo "## symlinks"
    for f in "{{ home }}/.zshrc" "{{ home }}/.config/starship.toml" "{{ home }}/.config/nvim" "{{ home }}/.config/mise/config.toml"; do
      if [[ -L "$f" ]]; then echo "  ok   $f -> $(readlink "$f")"; else echo "  NOT A SYMLINK: $f"; fi
    done

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
    mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; echo "seed   $dst"
