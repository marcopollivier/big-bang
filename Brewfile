# Big Bang — Brewfile
# Reinstall everything on a new machine with:
#   brew bundle --file=Brewfile      (or: just brew)
# Update this file after installing/removing tools with:
#   brew bundle dump --force --file=Brewfile

# --- Shell / CLI essentials ---
brew "starship"        # cross-shell prompt
brew "zsh-autosuggestions"  # sugestão de comando (cinza) a partir do histórico
brew "fzf"             # fuzzy finder (Ctrl-R, Ctrl-T)
brew "ripgrep"         # fast grep (used by Neovim/telescope)
brew "fd"              # fast find (used by Neovim/telescope)
brew "bat"             # cat with syntax highlighting
brew "eza"             # modern ls

# --- Editor & version manager ---
brew "neovim"          # editor / IDE (see nvim/)
brew "mise"            # runtime manager: go, java, kotlin, node, dotnet… (see mise/)

# --- Git / project tooling ---
brew "gh"              # GitHub CLI
brew "just"            # command runner — this repo's bootstrap (see justfile)
brew "lazygit"
brew "lazydocker"

# --- Cloud / infra ---
brew "awscli"
brew "kubernetes-cli"  # kubectl
brew "opentofu"
brew "ansible"         # ad-hoc only; remove if you don't use it
brew "podman"          # container engine (Mac: roda via `podman machine`)

# --- Terminal & fonts ---
cask "wezterm"
cask "font-hack-nerd-font"

# --- Apps ---
cask "visual-studio-code"  # instala também o CLI `code` no PATH
cask "google-drive"        # Google Drive (sync)
cask "bruno"               # client de API (alternativa a Insomnia/Postman)
cask "studio-3t"           # GUI de MongoDB (Studio 3T Free/Community)
