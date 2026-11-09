#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Inventário da máquina: o que está instalado, a versão e DE ONDE veio
# (brew formula, cask, mise, script curl, App Store, manual…).
#
# Rode ANTES do `just bootstrap` para ver o que ele vai fazer (missing = vai
# instalar; conflict = já existe por fora do brew e vai brigar com ele) e DEPOIS
# para ter o registro. O bootstrap já chama este script no final.
#
# Saída: Markdown no stdout e em ~/.big-bang/reports/report-<data>.md
# (~/.big-bang/reports/latest.md aponta pro último). ~/.big-bang é estado da
# máquina — fica fora do repo, nunca é versionado.
#
# Só precisa de brew + jq (o macOS 15+ já traz /usr/bin/jq), então funciona
# numa máquina zerada. Uso: scripts/report.sh  (ou: just report)
# ---------------------------------------------------------------------------
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
state_dir="${BIG_BANG_HOME:-$HOME/.big-bang}"
reports="$state_dir/reports"

for t in brew jq; do
  command -v "$t" >/dev/null 2>&1 || {
    echo "report: '$t' não encontrado (instale o Homebrew; jq vem no macOS 15+)" >&2
    exit 1
  }
done

prefix="$(brew --prefix)"
n_ok=0 n_missing=0 n_conflict=0 n_extra=0

# Linha de tabela Markdown com colunas alinhadas (legível no terminal também).
row() { printf '| %-26s | %-10s | %-14s | %s |\n' "$1" "$2" "$3" "$4"; }
head_row() {
  row "${1:-item}" status version "origem / caminho"
  printf '|%s|%s|%s|%s|\n' "----------------------------" "------------" "----------------" "------------------"
}

# Formula -> binário que ela põe no PATH, quando o nome difere (para detectar
# instalação por fora do brew). Formula sem binário: string vazia.
formula_bin() {
  case "$1" in
    neovim) echo nvim ;;
    ripgrep) echo rg ;;
    gnupg) echo gpg ;;
    awscli) echo aws ;;
    kubernetes-cli) echo kubectl ;;
    opentofu) echo tofu ;;
    zsh-autosuggestions) echo "" ;;
    *) echo "$1" ;;
  esac
}

# Caminho com ~ no lugar de $HOME (mais curto no relatório).
tilde() { echo "${1/#"$HOME"/\~}"; }

# Primeiro executável com esse nome no PATH que NÃO vem do brew (ou vazio).
outside_brew() {
  local bin="$1" p
  [[ -z "$bin" ]] && return 0
  p="$(command -v "$bin" 2>/dev/null || true)"
  [[ -n "$p" && "$p" != "$prefix"/* ]] && echo "$p"
  return 0
}

report() {
  echo "# Big Bang — relatório da máquina"
  echo
  echo "- **data:** $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "- **host:** $(scutil --get ComputerName 2>/dev/null || hostname)"
  echo "- **macOS:** $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
  echo "- **repo:** $repo @ $(git -C "$repo" rev-parse --short HEAD 2>/dev/null || echo '?')"
  echo "- **brew:** $(brew --version | head -1) em $prefix"
  echo
  echo "Status: \`ok\` instalado · \`missing\` o bootstrap vai instalar · \`conflict\` existe por fora"
  echo "do brew · \`shadowed\` instalado pelo brew, mas outro binário vem antes no PATH · \`extra\` fora do repo."

  local installed_json
  installed_json="$(brew info --json=v2 --installed 2>/dev/null)"

  # --- Brewfile: formulae ------------------------------------------------------
  echo
  echo "## Brewfile — formulae"
  echo
  head_row formula
  local f short ver bin out
  while read -r f; do
    [[ -z "$f" ]] && continue
    short="${f##*/}"
    bin="$(formula_bin "$short")"
    ver="$(jq -r --arg n "$f" --arg s "$short" \
      '.formulae[] | select(.full_name == $n or .name == $s) | .installed[-1].version' <<<"$installed_json")"
    out="$(outside_brew "$bin")"
    if [[ -n "$ver" ]]; then
      if [[ -n "$out" ]]; then
        row "$f" shadowed "$ver" "brew: $prefix/opt/$short — mas \`$bin\` resolve para $out"
        n_conflict=$((n_conflict + 1))
      else
        row "$f" ok "$ver" "brew: $prefix/opt/$short"
        n_ok=$((n_ok + 1))
      fi
    elif [[ -n "$out" ]]; then
      row "$f" conflict "-" "fora do brew: $out"
      n_conflict=$((n_conflict + 1))
    else
      row "$f" missing "-" "brew formula"
      n_missing=$((n_missing + 1))
    fi
  done < <(brew bundle list --formula --file="$repo/Brewfile" 2>/dev/null)

  # --- Brewfile: casks ---------------------------------------------------------
  echo
  echo "## Brewfile — casks"
  echo
  head_row cask
  local c missing_casks=() targets
  while read -r c; do
    [[ -z "$c" ]] && continue
    ver="$(jq -r --arg c "$c" '.casks[] | select(.token == $c or .full_token == $c) | .installed' <<<"$installed_json")"
    if [[ -n "$ver" ]]; then
      targets="$(jq -r --arg c "$c" \
        '[.casks[] | select(.token == $c or .full_token == $c) | .artifacts[] | select(has("app")) | .target] | join(", ")' <<<"$installed_json")"
      row "$c" ok "$ver" "cask: ${targets:-$prefix/Caskroom/$c}"
      n_ok=$((n_ok + 1))
    else
      missing_casks+=("$c")
    fi
  done < <(brew bundle list --cask --file="$repo/Brewfile" 2>/dev/null)

  # Cask ausente cujo .app já está em /Applications: instalado à mão. O
  # `brew bundle` falha nesse caso — adote o app em vez de reinstalar. Cask de
  # .pkg (ex.: google-drive) não declara o .app: cai no nome de exibição do cask.
  if ((${#missing_casks[@]})); then
    local info app
    info="$(brew info --cask --json=v2 "${missing_casks[@]}" 2>/dev/null || echo '{"casks":[]}')"
    for c in "${missing_casks[@]}"; do
      app="$(jq -r --arg c "$c" \
        '.casks[] | select(.token == $c or .full_token == $c)
          | ([.artifacts[] | select(has("app"))
              | (.target // ("/Applications/" + (.app[0] | split("/") | last)))] | first)
            // ("/Applications/" + .name[0] + ".app")' <<<"$info")"
      if [[ -n "$app" && -e "$app" ]]; then
        row "$c" conflict "-" "app manual em $app → brew install --cask --adopt $c"
        n_conflict=$((n_conflict + 1))
      else
        row "$c" missing "-" "brew cask"
        n_missing=$((n_missing + 1))
      fi
    done
  fi

  # --- Extras: instalados pelo brew mas fora do Brewfile -----------------------
  echo
  echo "## brew — fora do Brewfile"
  echo
  head_row pacote
  local listed
  listed="$(brew bundle list --all --file="$repo/Brewfile" 2>/dev/null | sed 's#.*/##')"
  while read -r f; do
    [[ -z "$f" ]] && continue
    grep -qxF "${f##*/}" <<<"$listed" && continue
    ver="$(jq -r --arg n "$f" '.formulae[] | select(.full_name == $n) | .installed[-1].version' <<<"$installed_json")"
    row "$f" extra "${ver:--}" "brew formula (instalada à mão)"
    n_extra=$((n_extra + 1))
  done < <(brew leaves --installed-on-request 2>/dev/null)
  while IFS=$'\t' read -r c ver; do
    [[ -z "$c" ]] && continue
    grep -qxF "$c" <<<"$listed" && continue
    row "$c" extra "$ver" "brew cask (instalado à mão)"
    n_extra=$((n_extra + 1))
  done < <(jq -r '.casks[] | [.token, .installed] | @tsv' <<<"$installed_json")

  # --- mise ---------------------------------------------------------------------
  echo
  echo "## mise — toolchains"
  echo
  if command -v mise >/dev/null 2>&1; then
    head_row tool
    while IFS=$'\t' read -r t ver inst active path src; do
      local st=ok
      [[ "$inst" != true ]] && st=missing && n_missing=$((n_missing + 1))
      [[ "$inst" == true && "$active" != true ]] && st=inactive
      [[ "$st" == ok ]] && n_ok=$((n_ok + 1))
      [[ "$src" == - ]] && src="nenhuma config — sobra de versão antiga"
      row "$t" "$st" "$ver" "${path:--} (de $src)"
    done < <(mise ls --json 2>/dev/null | jq -r '
      to_entries[] | .key as $t | .value[]
      | [$t, .version, (.installed | tostring), (.active | tostring), (.install_path // ""), (.source.path // "-")] | @tsv' |
      sed "s#$HOME#~#g")
  else
    echo "mise não instalado → o bootstrap instala (Brewfile) e roda \`mise install\`."
    n_missing=$((n_missing + 1))
  fi

  # --- oh-my-zsh + podman -------------------------------------------------------
  echo
  echo "## shell e containers"
  echo
  head_row item
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    row oh-my-zsh ok "$(git -C "$HOME/.oh-my-zsh" log -1 --format=%cs 2>/dev/null || echo '?')" \
      "script curl (just omz): ~/.oh-my-zsh"
    n_ok=$((n_ok + 1))
  else
    row oh-my-zsh missing "-" "script curl (just omz)"
    n_missing=$((n_missing + 1))
  fi
  if command -v podman >/dev/null 2>&1; then
    local state
    state="$(podman machine inspect podman-machine-default --format '{{.State}}' 2>/dev/null || true)"
    if [[ -n "$state" ]]; then
      row "podman machine" ok "$state" "podman machine init (just podman-machine)"
    else
      row "podman machine" missing "-" "podman machine init (just podman-machine)"
      n_missing=$((n_missing + 1))
    fi
  else
    row "podman machine" skip "-" "podman não instalado"
  fi

  # --- symlinks e seeds (listas do justfile) ------------------------------------
  echo
  echo "## symlinks (just link)"
  echo
  head_row "home"
  local src dst
  while read -r src dst; do
    [[ -z "$src" ]] && continue
    f="$HOME/$dst"
    if [[ -L "$f" && "$(readlink "$f")" == "$repo/$src" ]]; then
      row "$dst" ok "-" "→ repo/$src"
    elif [[ -L "$f" ]]; then
      row "$dst" conflict "-" "symlink para $(readlink "$f") — o link vai trocar"
      n_conflict=$((n_conflict + 1))
    elif [[ -e "$f" ]]; then
      row "$dst" conflict "-" "arquivo real — o link faz backup (.bak.*)"
      n_conflict=$((n_conflict + 1))
    else
      row "$dst" missing "-" "→ repo/$src"
      n_missing=$((n_missing + 1))
    fi
  done < <(just --justfile "$repo/justfile" --evaluate links)

  echo
  echo "## seeds (just seed — copiados só se não existirem)"
  echo
  head_row "home"
  while read -r src dst _; do
    [[ -z "$src" ]] && continue
    if [[ -e "$HOME/$dst" ]]; then
      row "$dst" ok "-" "existe (mantido)"
    else
      row "$dst" missing "-" "← repo/$src"
      n_missing=$((n_missing + 1))
    fi
  done < <(just --justfile "$repo/justfile" --evaluate seeds)

  # --- fora da gestão do repo (informativo, não entra no resumo) ---------------
  echo
  echo "## fora da gestão do repo (informativo)"
  echo
  echo "### /Applications sem cask"
  echo
  head_row app
  local cask_apps a origin
  cask_apps="$(jq -r '.casks[].artifacts[] | select(has("app")) | .target' <<<"$installed_json")"
  for a in /Applications/*.app; do
    # Symlink = app do sistema (ex.: Safari, no cryptex) — não é instalação.
    [[ -e "$a" && ! -L "$a" ]] || continue
    grep -qxF "$a" <<<"$cask_apps" && continue
    origin="manual / pkg"
    [[ -e "$a/Contents/_MASReceipt" ]] && origin="App Store"
    ver="$(defaults read "$a/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo -)"
    row "$(basename "$a" .app)" "-" "$ver" "$origin"
  done

  local d e tgt
  for d in /usr/local/bin "$HOME/.local/bin"; do
    [[ -d "$d" && "$d" != "$prefix/bin" ]] || continue
    echo
    echo "### $(tilde "$d")"
    echo
    head_row binário
    for e in "$d"/*; do
      [[ -e "$e" || -L "$e" ]] || continue
      tgt="$(readlink "$e" 2>/dev/null || true)"
      [[ "$tgt" == "$prefix"/* ]] && continue
      row "$(basename "$e")" "-" "-" "${tgt:-arquivo local}"
    done
  done

  if command -v npm >/dev/null 2>&1; then
    echo
    echo "### npm -g ($(tilde "$(npm root -g 2>/dev/null)"))"
    echo
    head_row pacote
    while IFS=$'\t' read -r p ver; do
      [[ -z "$p" ]] && continue
      row "$p" "-" "$ver" "npm global"
    done < <(npm ls -g --depth=0 --json 2>/dev/null | jq -r '.dependencies // {} | to_entries[] | [.key, .value.version] | @tsv')
  fi

  echo
  echo "## resumo"
  echo
  echo "**$n_ok ok · $n_missing missing · $n_conflict conflict · $n_extra extra**"
  ((n_conflict)) && echo && echo "Resolva os \`conflict\` antes do \`just bootstrap\` (ver coluna origem)."
  return 0
}

mkdir -p "$reports" && chmod 700 "$state_dir"
out="$reports/report-$(date +%Y%m%d-%H%M%S).md"
report | tee "$out"
ln -sfn "$(basename "$out")" "$reports/latest.md"
echo
echo "→ salvo em $(tilde "$out") (latest: $(tilde "$reports")/latest.md)"
