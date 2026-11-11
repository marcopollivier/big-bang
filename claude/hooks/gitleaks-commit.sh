#!/usr/bin/env bash
# PreToolUse (Bash) — roda o gitleaks no que vai ser commitado, antes do `git commit`.
#
# Só age quando o comando contém `git commit`. Achou segredo: bloqueia (exit 2) e
# lista arquivo:linha + regra — NUNCA o valor (--redact, e o report só é lido por
# campos). Sem gitleaks instalado: avisa e deixa passar (o `just doctor` acusa).
# Testes: claude/hooks/test.sh
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"

# git [opções globais] commit — captura um -C <dir> se houver
re='(^|[;&|[:space:](])git(([[:space:]]+-(C|c)[[:space:]]+[^[:space:]]+|[[:space:]]+--[a-z-]+)*)[[:space:]]+commit([[:space:]]|$)'
[[ "$cmd" =~ $re ]] || exit 0
dir="${cwd:-$PWD}"
if [[ "${BASH_REMATCH[2]}" =~ -C[[:space:]]+([^[:space:]]+) ]]; then
  c="${BASH_REMATCH[1]//\"/}"
  c="${c//\'/}"
  [[ "$c" = /* ]] && dir="$c" || dir="$dir/$c"
fi
git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || exit 0

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "aviso: gitleaks não instalado — commit não foi escaneado (brew install gitleaks / just brew)" >&2
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --staged = o que está no índice. Com `commit -a`/`--all` o git também leva as
# mudanças não staged de arquivos versionados: escaneia o diff do working tree também.
scan() { # $1 = sufixo do report, demais = flags extras
  local out="$tmp/$1.json"
  shift
  (cd "$dir" && gitleaks git --pre-commit "$@" --redact --no-banner --log-level error \
    --report-format json --report-path "$out" . >/dev/null 2>&1)
  local rc=$?
  [[ $rc -eq 1 && -s "$out" ]] && jq -r '.[] | "  - \(.File):\(.StartLine)  [\(.RuleID)]"' "$out"
  return $rc
}

findings="$(scan staged --staged)"
rc=$?
if [[ "$cmd" =~ commit[^\;\&\|]*([[:space:]]-[a-zA-Z]*a[a-zA-Z]*|[[:space:]]--all)([[:space:]]|$) ]]; then
  more="$(scan worktree)"
  r2=$?
  [[ $r2 -eq 1 ]] && rc=1 && findings="$(printf '%s\n%s' "$findings" "$more" | sed '/^$/d' | sort -u)"
fi

if [[ $rc -eq 1 ]]; then
  {
    echo "BLOQUEADO pelo hook gitleaks-commit: possível segredo no que vai ser commitado:"
    echo "$findings"
    echo "Remova o segredo do arquivo (use variável de ambiente / ~/.zshrc.local) e tire-o do stage."
    echo "Se já foi exposto antes, avise o usuário para rotacionar. Falso positivo: gitleaks:allow na linha ou .gitleaksignore."
  } >&2
  exit 2
elif [[ $rc -ne 0 ]]; then
  echo "aviso: gitleaks falhou (exit $rc) — commit não foi escaneado" >&2
fi
exit 0
