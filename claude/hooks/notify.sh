#!/usr/bin/env bash
# Notification / Stop — notificação do macOS quando o Claude termina a vez ou
# precisa de você (permissão, pergunta). Útil com várias sessões/abas abertas.
# Fora do macOS (sem osascript) não faz nada. Sempre exit 0.
set -uo pipefail

command -v osascript >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
project="${cwd##*/}"

case "$event" in
Notification) msg="$(jq -r '.message // "Precisa da sua atenção"' <<<"$input")" ;;
Stop) msg="Terminou" ;;
*) exit 0 ;;
esac

# Texto via argv (não interpolado no AppleScript) — nada de injeção pelo conteúdo
osascript -e 'on run argv' \
  -e 'display notification (item 1 of argv) with title (item 2 of argv)' \
  -e 'end run' "$msg" "Claude Code${project:+ · $project}" >/dev/null 2>&1 || true
exit 0
