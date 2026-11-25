#!/usr/bin/env bash
# Processos (de qualquer stack) com cwd dentro de um worktree ligado: dev server,
# watcher, REPL… ficam órfãos quando o worktree some. O worktree aparece como
# "attention" no inventário; aqui sai o comando para encerrar cada um.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/_common.sh
. "$here/_common.sh"
# shellcheck source=SCRIPTDIR/../lib.sh
. "$here/../lib.sh"
cd "${1:-.}" || exit 0
# o inventory.sh exporta a tabela de cwd que já montou (o lsof custa ~1s); sem gh aqui
cwds="${WU_CWDS:-}"
WU_QUICK=1 wu_init >/dev/null 2>&1 || exit 0
if [[ -n "$cwds" ]]; then WU_CWDS="$cwds"; else wu_load_cwds; fi
while IFS="$TAB" read -r path _; do
  [[ -z "$path" || ! -d "$path" ]] && continue
  real="$(wu_realpath "$path")"
  awk -F'\t' -v p="$real" '$3==p || index($3, p "/")==1 {print $1 "\t" $2}' <<<"$WU_CWDS" |
    while IFS="$TAB" read -r pid cmd; do
      row processes "$pid" "$cmd rodando em $path" "kill $pid"
    done
done <<<"$(wu_worktrees)"
