#!/usr/bin/env bash
# Hook SessionStart do wrap-up: se o repo da sessão tem worktree/branch pronto para
# limpar, avisa em UMA linha e sugere o /wrap-up. Só avisa: nunca apaga nada.
#
# Rápido e silencioso de propósito: usa o inventory --quick (offline, sem gh, sem
# processos), sai sem output fora de repo git e nunca falha a sessão (sempre exit 0).
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
input="$(cat 2>/dev/null || true)"
cwd=""
command -v jq >/dev/null 2>&1 && cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
cd "${cwd:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

ready="$("$here/scripts/inventory.sh" --quick 2>/dev/null |
  awk -F'\t' '$3=="ready" && ($1=="checkout" || $1=="worktree" || $1=="branch") {print $1 " " $2}')" || exit 0
[[ -n "$ready" ]] || exit 0
n="$(wc -l <<<"$ready" | tr -d ' ')"
list="$(tr '\n' ',' <<<"$ready" | sed 's/,$//; s/,/, /g')"

msg="wrap-up: $n item(ns) mergeado(s) pronto(s) para limpar neste repo — rode /wrap-up"
ctx="Inventário rápido (offline) do wrap-up: $n item(ns) já mergeado(s) e pronto(s) para limpar neste repo ($list). Não apague nada por conta própria: se o usuário disser que terminou o trabalho ou pedir limpeza, sugira o /wrap-up."
if command -v jq >/dev/null 2>&1; then
  jq -nc --arg m "$msg" --arg c "$ctx" \
    '{systemMessage: $m, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
else
  printf '%s\n' "$ctx" # texto puro no stdout do SessionStart também vira contexto
fi
exit 0
