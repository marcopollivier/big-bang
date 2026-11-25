#!/usr/bin/env bash
# Inventário do wrap-up (SÓ LEITURA): o que dá para limpar no repo atual.
#
# Uso:   inventory.sh [--quick]
#        --quick = offline e rápido (para o hook SessionStart): sem gh, sem olhar
#        processos e sem probes de stack. Só ancestralidade e upstream sumido.
# Saída: TSV estável, uma linha por item, sem cabeçalho:
#        kind<TAB>target<TAB>status<TAB>reason<TAB>action
#        kind   = checkout | worktree | branch | remote | stash | meta | stack:<nome>
#        status = ready | attention | keep | info   (ver lib.sh)
#        action = o que o apply.sh faria (switch-default, remove-worktree, delete-branch),
#                 "manual: <cmd>" (só o usuário roda), um comando sugerido (stack) ou "-".
# Não faz fetch: rode `git fetch --prune` antes (a skill faz).
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
[[ "${1:-}" == --quick ]] && export WU_QUICK=1
# shellcheck source=SCRIPTDIR/lib.sh
. "$here/lib.sh"
wu_init || exit 1
cd "$WU_ROOT" || exit 1

row() { printf '%s\t%s\t%s\t%s\t%s\n' "$@"; }
action_for() { # $1 = status, $2 = action se ready
  if [[ "$1" == ready ]]; then printf '%s' "$2"; else printf '%s' '-'; fi
}

row meta base info "merge comparado com $WU_BASE" -
if [[ "$WU_QUICK" != 1 && "$WU_GH_OK" != 1 ]]; then
  row meta gh info "gh indisponível (sem gh, auth ou rede): squash merge e PRs abertos não verificados" -
fi

# Checkout principal numa branch que não é a default
rb="$(wu_root_branch)"
if [[ -n "$rb" ]]; then
  IFS="$TAB" read -r st why _ <<<"$(wu_classify_checkout "$rb")"
  row checkout "$rb" "$st" "checkout principal em $rb: $why" "$(action_for "$st" switch-default)"
fi

# Worktrees ligados (a branch de cada um vai junto: o apply.sh apaga depois de remover)
in_worktree=""
while IFS="$TAB" read -r path branch sha locked prunable; do
  [[ -z "$path" ]] && continue
  [[ -n "$branch" ]] && in_worktree="$in_worktree$branch$TAB"
  IFS="$TAB" read -r st why _ <<<"$(wu_classify_worktree "$path" "$branch" "$sha" "$locked" "$prunable")"
  row worktree "$path" "$st" "${branch:-(detached)}: $why" "$(action_for "$st" remove-worktree)"
done <<<"$(wu_worktrees)"

# Branches locais soltas (nem default, nem no checkout principal, nem num worktree)
while IFS= read -r b; do
  [[ -z "$b" || "$b" == "$WU_DEFAULT" || "$b" == "$rb" ]] && continue
  [[ "$TAB$in_worktree" == *"$TAB$b$TAB"* ]] && continue
  IFS="$TAB" read -r st why _ <<<"$(wu_classify_branch "$b")"
  row branch "$b" "$st" "$why" "$(action_for "$st" delete-branch)"
done <<<"$(git for-each-ref --format='%(refname:short)' refs/heads/)"

# Branches remotas já mergeadas: só listar (apagar remoto é sempre com você)
while IFS="$TAB" read -r rname rsha; do
  short="${rname#"$WU_REMOTE"/}"
  [[ -z "$rname" || "$rname" == "$WU_REMOTE" || "$short" == HEAD || "$short" == "$WU_DEFAULT" ]] && continue
  proof="$(wu_merge_proof "$short" "$rsha")"
  [[ -z "$proof" ]] && continue
  [[ "$proof" == ancestor && "$rsha" == "$(git rev-parse "$WU_BASE")" ]] && continue # recém-criada
  row remote "$rname" info "branch remota mergeada ($proof)" "manual: git push $WU_REMOTE --delete $short"
done <<<"$(git for-each-ref --format="%(refname:short)$TAB%(objectname)" "refs/remotes/$WU_REMOTE/")"

# Stashes: só listar
while IFS="$TAB" read -r ref age msg; do
  [[ -z "$ref" ]] && continue
  row stash "$ref" info "$age: $msg" "manual: git stash drop $ref"
done <<<"$(git stash list --format="%gd$TAB%cr$TAB%s" 2>/dev/null)"

# Probes de stack (só no modo completo): cada uma decide se a stack existe no repo
if [[ "$WU_QUICK" != 1 ]]; then
  export WU_CWDS
  for p in "$here"/probes/*.sh; do
    [[ -x "$p" ]] && "$p" "$WU_ROOT"
  done
fi
exit 0
