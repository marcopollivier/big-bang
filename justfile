# Big Bang — bootstrap & maintenance.  Run `just` to list recipes.
# Fresh machine: install Homebrew, then `brew install just`, then `just bootstrap`.

set shell := ["bash", "-euc"]

repo := justfile_directory()
home := env_var('HOME')

# Symlinks (repo -> home), uma lista só, usada por `link` e por `doctor`.
# Formato: <caminho no repo> <caminho na home>, separados por espaço.
# Skills do Claude entram uma a uma: ~/.claude/skills/ tem pastas que não são do
# repo (ex.: `synced/`, gerenciada pela org), então a pasta inteira não vira symlink.
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
claude/CLAUDE.md           .claude/CLAUDE.md
claude/commands            .claude/commands
claude/agents              .claude/agents
claude/output-styles       .claude/output-styles
claude/keybindings.json    .claude/keybindings.json
claude/skills/adr          .claude/skills/adr
'''

# Versão mínima do cmux com Extensions (beta) e wrapper do Claude (ver cmux/README.md).
# O cask é auto_updates, então o número do brew não reflete o app: `doctor` confere o binário.
cmux_min := "0.64.22"

# Templates com identidade/segredo (repo -> home), copiados só se não existirem.
# Uma lista só, usada por `seed` e por `report`. Formato: <caminho no repo> <caminho
# na home> [template] — template substitui __REPO__ pelo caminho deste clone.
seeds := '''
dotfiles/.zshrc.local.example .zshrc.local
dotfiles/.gitconfig           .gitconfig
dotfiles/.wakatime.cfg        .wakatime.cfg
dotfiles/.aws/config          .aws/config
dotfiles/.npmrc               .npmrc
dotfiles/.clojure/deps.edn    .clojure/deps.edn
claude/settings.json          .claude/settings.json       template
claude/usage-budget.example   .claude/usage-budget
claude/automode.local.example .claude/automode.local.json
'''

# Show available recipes
default:
    @just --list

# Full setup on a new machine (idempotent)
bootstrap: brew omz link mise-install seed automode claude-hooks podman-machine
    @just report >/dev/null && echo "→ inventário salvo em ~/.big-bang/reports/latest.md"
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
    #!/usr/bin/env bash
    set -euo pipefail
    printf '%s\n' "{{ seeds }}" | while read -r src dst mode; do
      [[ -z "$src" ]] && continue
      if [[ "$mode" == template ]]; then just _seed_template "{{ repo }}/$src" "{{ home }}/$dst"
      else just _seed "{{ repo }}/$src" "{{ home }}/$dst"; fi
    done
    echo "→ Now fill identity/keys in ~/.gitconfig, ~/.wakatime.cfg and ~/.zshrc.local"
    echo "→ Set your monthly token limit (US\$) in ~/.claude/usage-budget"
    echo "→ GPG: commits são assinados por padrão — crie uma chave (gpg --full-generate-key)"
    echo "  e preencha user.signingKey, ou rode: git config --global commit.gpgsign false"

# Claude Code auto mode: grava claude/automode.json (+ ~/.claude/automode.local.json)
# como a chave `autoMode` do ~/.claude/settings.json — o único lugar (além de managed
# settings) de onde o classificador lê isso. Só toca nessa chave; idempotente.
automode:
    #!/usr/bin/env bash
    set -euo pipefail
    settings="{{ home }}/.claude/settings.json"
    want="$(just _automode_expected)"
    [[ -f "$settings" ]] || { mkdir -p "$(dirname "$settings")"; echo '{}' >"$settings"; chmod 600 "$settings"; }
    if [[ "$(jq -S '.autoMode // null' "$settings")" == "$(jq -S . <<<"$want")" ]]; then
      echo "ok     $settings autoMode already in sync"; exit 0
    fi
    tmp="$(mktemp)"
    jq --argjson am "$want" '.autoMode = $am' "$settings" >"$tmp" && cat "$tmp" >"$settings" && rm -f "$tmp"
    echo "write  $settings autoMode (check: claude auto-mode config)"

# Claude Code hooks: grava claude/hooks.json (com __REPO__ resolvido) como a chave
# `hooks` do ~/.claude/settings.json. Só toca nessa chave; idempotente. Ver claude/README.md.
claude-hooks:
    #!/usr/bin/env bash
    set -euo pipefail
    settings="{{ home }}/.claude/settings.json"
    want="$(just _claude_hooks_expected)"
    [[ -f "$settings" ]] || { mkdir -p "$(dirname "$settings")"; echo '{}' >"$settings"; chmod 600 "$settings"; }
    if [[ "$(jq -S '.hooks // null' "$settings")" == "$(jq -S . <<<"$want")" ]]; then
      echo "ok     $settings hooks already in sync"; exit 0
    fi
    tmp="$(mktemp)"
    jq --argjson h "$want" '.hooks = $h' "$settings" >"$tmp" && cat "$tmp" >"$settings" && rm -f "$tmp"
    echo "write  $settings hooks (check: /hooks numa sessão nova do Claude)"

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

# Inventory: what's installed, its version and where it came from (-> ~/.big-bang/reports/)
# Rode antes do bootstrap: missing = vai instalar; conflict = já existe por fora do brew.
report:
    @bash "{{ repo }}/scripts/report.sh"

# Sanity check: tools, symlinks, git identity/GPG, Brewfile, cmux (exit 1 on any failure)
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    fail=0
    echo "## tools"
    for t in brew mise nvim starship fzf git just podman gh jq gpg git-lfs gitleaks; do
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
    # O WezTerm prefere ~/.wezterm.lua a ~/.config/wezterm/wezterm.lua: um arquivo
    # antigo ali esconde o symlink do repo em silêncio.
    if [[ -e "{{ home }}/.wezterm.lua" ]]; then
      echo "  SHADOWED: ~/.wezterm.lua overrides ~/.config/wezterm/wezterm.lua (move it away)"; fail=1
    fi
    # O mise lê ~/.tool-versions (legado do asdf), e as versões dele passam por cima das do repo.
    if [[ -e "{{ home }}/.tool-versions" ]]; then
      echo "  SHADOWED: ~/.tool-versions (asdf leftover) overrides mise/config.toml (move it away)"; fail=1
    fi
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
    echo "## claude"
    cs="{{ home }}/.claude/settings.json"
    if [[ "$(jq -S '.autoMode // null' "$cs" 2>/dev/null)" == "$(just _automode_expected | jq -S .)" ]]; then
      echo "  ok   autoMode in sync with claude/automode.json"
    else
      echo "  autoMode DIVERGENT from claude/automode.json (run: just automode)"; fail=1
    fi
    if [[ -n "$(jq -r '.statusLine.command // empty' "$cs" 2>/dev/null)" ]]; then
      echo "  ok   statusLine configured"
    else
      echo "  statusLine MISSING in $cs (copy the key from claude/settings.json)"
    fi
    if [[ "$(jq -S '.hooks // null' "$cs" 2>/dev/null)" == "$(just _claude_hooks_expected | jq -S .)" ]]; then
      echo "  ok   hooks in sync with claude/hooks.json"
    else
      echo "  hooks DIVERGENT from claude/hooks.json (run: just claude-hooks)"; fail=1
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

# Standalone (not in `bootstrap`): depende da CLI `claude`, e MCP de terceiro em
# máquina de trabalho precisa de aprovação. Adiciona (user scope) os servidores de
# claude/mcp.json que ainda não existem; não mexe nos que já estão lá.
# Add the MCP servers listed in claude/mcp.json (user scope)
claude-mcp:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v claude >/dev/null || { echo "claude CLI não encontrada"; exit 1; }
    while IFS=$'\t' read -r name cfg; do
      if claude mcp get "$name" >/dev/null 2>&1; then echo "ok     mcp $name (already configured)"; continue; fi
      claude mcp add-json --scope user "$name" "$cfg" >/dev/null && echo "add    mcp $name"
    done < <(jq -r '.servers | to_entries[] | [.key, (.value | tojson)] | @tsv' "{{ repo }}/claude/mcp.json")
    echo "→ confira com: claude mcp list"

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

# autoMode esperado: claude/automode.json com __REPO__/__GH_USER__ resolvidos (o user
# vem do remote origin, então funciona em fork) + listas do ~/.claude/automode.local.json
_automode_expected:
    #!/usr/bin/env bash
    set -euo pipefail
    user="$(git -C "{{ repo }}" remote get-url origin | sed -E 's#.*github\.com[:/]([^/]+)/.*#\1#')"
    base="$(sed -e "s|__REPO__|{{ repo }}|g" -e "s|__GH_USER__|$user|g" "{{ repo }}/claude/automode.json")"
    extra='{}'
    [[ -f "{{ home }}/.claude/automode.local.json" ]] && extra="$(cat "{{ home }}/.claude/automode.local.json")"
    jq -n --argjson a "$base" --argjson b "$extra" '
      reduce ($b | del(._comment) | to_entries[]) as $e ($a;
        if ($e.value | type) == "array"
        then (if ($e.value | length) > 0 then .[$e.key] = ((.[$e.key] // []) + $e.value) else . end)
        else .[$e.key] = $e.value end)'

# hooks esperados: claude/hooks.json com __REPO__ trocado pelo caminho deste clone
_claude_hooks_expected:
    @sed "s|__REPO__|{{ repo }}|g" "{{ repo }}/claude/hooks.json" | jq -c .

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
