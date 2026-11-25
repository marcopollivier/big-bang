#!/usr/bin/env bash
# Containers do projeto (compose) e lixo do engine. Usa o engine que existir e
# responder: docker (Docker Desktop/Colima) ou podman.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/_common.sh
. "$here/_common.sh"
root="${1:-.}"

eng=""
for e in docker podman; do
  if command -v "$e" >/dev/null 2>&1 && "$e" ps -q >/dev/null 2>&1; then eng="$e" && break; fi
done
[[ -n "$eng" ]] || exit 0

# Containers/volumes de compose cujo projeto tem o nome de um worktree deste repo
# (o compose usa o nome da pasta): sobram quando o worktree é removido.
if has_file "$root" 'compose.y*ml' 'docker-compose.y*ml'; then
  git -C "$root" worktree list --porcelain | sed -n 's/^worktree //p' | while IFS= read -r wt; do
    proj="$(basename "$wt" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')"
    n="$("$eng" ps -aq --filter "label=com.docker.compose.project=$proj" 2>/dev/null | wc -l | tr -d ' ')"
    v="$("$eng" volume ls -q --filter "label=com.docker.compose.project=$proj" 2>/dev/null | wc -l | tr -d ' ')"
    [[ "$n" -gt 0 ]] && row containers "$proj" "$n container(s) do compose '$proj' (+$v volume(s); para apagar os volumes também: down -v)" "$eng compose -p $proj down"
  done
fi

# Lixo do engine (vale para a máquina toda, não só este repo)
n="$("$eng" images -q -f dangling=true 2>/dev/null | wc -l | tr -d ' ')"
[[ "$n" -gt 0 ]] && row containers images "$n imagem(ns) <none> (máquina toda)" "$eng image prune -f"
n="$("$eng" ps -aq -f status=exited 2>/dev/null | wc -l | tr -d ' ')"
[[ "$n" -gt 0 ]] && row containers stopped "$n container(s) parado(s) (máquina toda)" "$eng container prune -f"
exit 0
