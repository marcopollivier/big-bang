#!/usr/bin/env bash
# Executa UM item do inventário, revalidando-o antes (o estado pode ter mudado entre
# o inventário e o seu OK). Só age em status "ready"; qualquer outro → recusa (exit 1).
#
# Uso: apply.sh worktree <caminho> | branch <nome> | checkout <nome>
#   worktree → git worktree remove (SEM --force) + prune + rmdir da pasta-mãe vazia,
#              e depois apaga a branch dele, se ela também estiver pronta.
#   branch   → git branch -d; se o -d recusar (squash, ou HEAD fora da main), usa -D,
#              porque a prova de merge já foi checada aqui com regra mais precisa que a do -d.
#   checkout → no checkout principal: switch para a default + pull --ff-only, e apaga a branch.
# Nunca apaga branch remota, nunca usa --force em worktree, nunca mata processo.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
. "$here/lib.sh"

kind="${1:-}" target="${2:-}"
[[ -n "$kind" && -n "$target" ]] || {
  echo "uso: apply.sh worktree <caminho> | branch <nome> | checkout <nome>" >&2
  exit 2
}
wu_init || exit 1
cd "$WU_ROOT" || exit 1

refuse() { echo "RECUSADO $kind $target: $1" >&2 && exit 1; }

# Revalida a branch e apaga. $1 = branch. Retorna 1 se não estiver pronta.
delete_branch() {
  local b="$1" st why proof err
  IFS="$TAB" read -r st why proof <<<"$(wu_classify_branch "$b")"
  [[ "$st" == ready ]] || { echo "mantida   branch $b ($why)" && return 1; }
  if err="$(git branch -d "$b" 2>&1)"; then
    echo "apagada   branch $b ($why)"
  elif [[ -n "$proof" ]] && git branch -D "$b" >/dev/null; then
    echo "apagada   branch $b com -D: o -d recusou (${err%%$'\n'*}), mas há prova de merge ($proof)"
  else
    echo "ERRO ao apagar a branch $b: $err" >&2 && return 1
  fi
}

case "$kind" in
worktree)
  line="$(wu_worktrees | awk -F'\t' -v p="$target" '$1==p')"
  [[ -n "$line" ]] || refuse "não é um worktree ligado deste repo (veja git worktree list)"
  IFS="$TAB" read -r path branch sha locked prunable <<<"$line"
  IFS="$TAB" read -r st why _ <<<"$(wu_classify_worktree "$path" "$branch" "$sha" "$locked" "$prunable")"
  [[ "$st" == ready ]] || refuse "$why"
  if [[ "$prunable" == 1 ]]; then
    git worktree prune && echo "podado    worktree $path (pasta já não existia)"
  else
    git worktree remove "$path" || refuse "git worktree remove falhou (nada foi forçado)"
    git worktree prune
    echo "removido  worktree $path"
    parent="$(dirname "$path")"
    if [[ "$parent" != "$HOME" && "$parent" != "$(dirname "$WU_ROOT")" ]] && rmdir "$parent" 2>/dev/null; then
      echo "removida  pasta vazia $parent"
    fi
  fi
  [[ -z "$branch" ]] || delete_branch "$branch" || true
  ;;
branch)
  [[ "$target" != "$WU_DEFAULT" ]] || refuse "é a branch default"
  if git worktree list --porcelain | grep -qx "branch refs/heads/$target"; then
    refuse "está em uso num worktree/checkout (limpe o worktree primeiro)"
  fi
  IFS="$TAB" read -r st why _ <<<"$(wu_classify_branch "$target")"
  [[ "$st" == ready ]] || refuse "$why"
  delete_branch "$target" || exit 1
  ;;
checkout)
  [[ "$(wu_root_branch)" == "$target" ]] || refuse "o checkout principal não está em $target"
  IFS="$TAB" read -r st why _ <<<"$(wu_classify_checkout "$target")"
  [[ "$st" == ready ]] || refuse "$why"
  git switch -q "$WU_DEFAULT" || refuse "git switch $WU_DEFAULT falhou"
  echo "trocado   checkout principal para $WU_DEFAULT"
  if [[ -n "$(git for-each-ref --format='%(upstream)' "refs/heads/$WU_DEFAULT")" ]]; then
    if git pull -q --ff-only; then echo "atualizado $WU_DEFAULT (pull --ff-only)"; else echo "AVISO: pull --ff-only falhou em $WU_DEFAULT" >&2; fi
  fi
  delete_branch "$target" || exit 1
  ;;
*)
  echo "tipo desconhecido: $kind (use worktree | branch | checkout)" >&2
  exit 2
  ;;
esac
