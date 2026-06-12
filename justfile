# Big Bang — bootstrap & maintenance.  Run `just` to list recipes.
# Fresh machine: install Homebrew, then `brew install just`, then `just bootstrap`.

set shell := ["bash", "-uc"]

repo := justfile_directory()
home := env_var('HOME')

# Show available recipes
default:
    @just --list

# Full setup on a new machine (idempotent)
bootstrap: brew link mise-install seed
    @echo ""
    @echo "✅ Bootstrap complete. Open a new terminal (or run: exec zsh)."

# Install/upgrade everything in the Brewfile
brew:
    brew bundle --file="{{ repo }}/Brewfile"

# Install the toolchains pinned in mise/config.toml
mise-install:
    mise install

# Symlink shared, secret-free configs into place (idempotent; backs up real files)
link:
    just _link "{{ repo }}/dotfiles/.zshrc"            "{{ home }}/.zshrc"
    just _link "{{ repo }}/dotfiles/.gitignore.global" "{{ home }}/.gitignore.global"
    just _link "{{ repo }}/dotfiles/.opentofurc"       "{{ home }}/.opentofurc"
    just _link "{{ repo }}/starship/starship.toml"     "{{ home }}/.config/starship.toml"
    just _link "{{ repo }}/nvim"                        "{{ home }}/.config/nvim"
    just _link "{{ repo }}/mise/config.toml"           "{{ home }}/.config/mise/config.toml"

# Seed template files that hold identity/secrets — only if missing (never clobbers)
seed:
    just _seed "{{ repo }}/dotfiles/.zshrc.local.example" "{{ home }}/.zshrc.local"
    just _seed "{{ repo }}/dotfiles/.gitconfig"           "{{ home }}/.gitconfig"
    just _seed "{{ repo }}/dotfiles/.wakatime.cfg"        "{{ home }}/.wakatime.cfg"
    just _seed "{{ repo }}/dotfiles/.aws/config"          "{{ home }}/.aws/config"
    just _seed "{{ repo }}/dotfiles/.clojure/deps.edn"    "{{ home }}/.clojure/deps.edn"
    @echo "→ Now fill identity/keys in ~/.gitconfig, ~/.wakatime.cfg and ~/.zshrc.local"

# Update the Brewfile from what's currently installed
brew-dump:
    brew bundle dump --force --file="{{ repo }}/Brewfile"

# Sanity check: tools present + symlinks resolved
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    echo "## tools"
    for t in brew mise nvim starship fzf git just; do
      printf "  %-10s %s\n" "$t" "$(command -v "$t" || echo MISSING)"
    done
    echo "## symlinks"
    for f in "{{ home }}/.zshrc" "{{ home }}/.config/starship.toml" "{{ home }}/.config/nvim" "{{ home }}/.config/mise/config.toml"; do
      if [[ -L "$f" ]]; then echo "  ok   $f -> $(readlink "$f")"; else echo "  NOT A SYMLINK: $f"; fi
    done

# Open a PR for the current branch in the browser (requires: gh auth login)
pr:
    gh pr create --web --fill

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
