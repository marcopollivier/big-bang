#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit) — formata o arquivo que o Claude acabou de mexer,
# com o formatter da linguagem, SÓ se ele estiver instalado. Nunca bloqueia: sai
# sempre 0 e fica em silêncio (formatter ausente ou com erro = nada acontece).
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
f="$(jq -r '.tool_input.file_path // empty' <<<"$input")"
[[ -n "$f" && -f "$f" ]] || exit 0

has() { command -v "$1" >/dev/null 2>&1; }

case "$f" in
*.go)
  if has goimports; then goimports -w "$f"; elif has gofmt; then gofmt -w "$f"; fi
  ;;
*.lua) has stylua && stylua --search-parent-directories "$f" ;;
*.kt | *.kts) has ktlint && ktlint --format --log-level=none "$f" ;;
*.cs) has csharpier && csharpier format "$f" ;;
*.sh | *.bash) has shfmt && shfmt -w -i 2 -ci "$f" ;;
*.tf | *.tofu)
  if has tofu; then tofu fmt "$f"; elif has terraform; then terraform fmt "$f"; fi
  ;;
esac >/dev/null 2>&1

exit 0
