# shellcheck shell=bash
# Biblioteca do wrap-up: classifica worktrees e branches do repo atual. SÓ LEITURA.
# Usada pelo inventory.sh (lista tudo) e pelo apply.sh (revalida um item antes de agir),
# para que os dois decidam com a MESMA regra.
#
# Status:  ready     = pode limpar (mergeado, limpo, sem nada local a perder)
#          attention = não apaga; precisa de você olhar (motivo na coluna reason)
#          keep      = trabalho em andamento (PR aberto, commits não enviados…)
#          info      = só listar (remota mergeada, stash, recurso da stack)
# Prova de merge (coluna proof): "ancestor" (merge/ff: contido em <remote>/<default>)
# ou "squash #N" (PR mergeado no gh cujo headRefOid == SHA local).
#
# Compatível com o bash 3.2 do macOS: nada de mapfile nem array associativo; o
# estado fica em strings TSV consultadas com awk.

WU_REMOTE="${WRAP_UP_REMOTE:-origin}"
WU_GH="${WRAP_UP_GH:-gh}"
WU_QUICK="${WU_QUICK:-0}"
TAB=$'\t'

# Raiz (checkout principal), branch default e a ref usada como base do merge.
wu_init() {
  WU_ROOT="$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')"
  [[ -n "$WU_ROOT" ]] || { echo "wrap-up: não é um repositório git" >&2; return 1; }
  WU_DEFAULT="$(git symbolic-ref --short -q "refs/remotes/$WU_REMOTE/HEAD" 2>/dev/null)"
  WU_DEFAULT="${WU_DEFAULT#"$WU_REMOTE"/}"
  if [[ -z "$WU_DEFAULT" ]]; then
    local b
    for b in main master; do
      if git rev-parse -q --verify "refs/remotes/$WU_REMOTE/$b" >/dev/null ||
        git rev-parse -q --verify "refs/heads/$b" >/dev/null; then
        WU_DEFAULT="$b" && break
      fi
    done
  fi
  [[ -n "$WU_DEFAULT" ]] || { echo "wrap-up: não achei a branch default (main/master)" >&2; return 1; }
  if git rev-parse -q --verify "refs/remotes/$WU_REMOTE/$WU_DEFAULT" >/dev/null; then
    WU_BASE="$WU_REMOTE/$WU_DEFAULT"
  else
    WU_BASE="$WU_DEFAULT"
  fi
  WU_GH_OK=0 WU_MERGED_PRS="" WU_OPEN_PRS="" WU_CWDS=""
  if [[ "$WU_QUICK" != 1 ]]; then
    wu_load_prs
    wu_load_cwds
  fi
  return 0
}

# PRs do gh em TSV "número<TAB>headRefName<TAB>headRefOid". Sem gh/auth/rede: WU_GH_OK=0
# e vale só a prova por ancestralidade (nunca é motivo para apagar mais).
wu_load_prs() {
  command -v jq >/dev/null 2>&1 || return 0
  command -v "$WU_GH" >/dev/null 2>&1 || return 0
  local merged open q='.[] | [.number, .headRefName, .headRefOid] | @tsv'
  merged="$(cd "$WU_ROOT" && "$WU_GH" pr list --state merged --limit 200 --json number,headRefName,headRefOid 2>/dev/null)" || return 0
  open="$(cd "$WU_ROOT" && "$WU_GH" pr list --state open --limit 200 --json number,headRefName,headRefOid 2>/dev/null)" || return 0
  WU_MERGED_PRS="$(jq -r "$q" <<<"$merged" 2>/dev/null)" || return 0
  WU_OPEN_PRS="$(jq -r "$q" <<<"$open" 2>/dev/null)" || return 0
  WU_GH_OK=1
}

# cwd de cada processo do usuário, em TSV "pid<TAB>comando<TAB>cwd". Exclui este
# script e o shell que o chamou (o cwd deles não é "trabalho rodando").
wu_load_cwds() {
  local self="$$" parent="$PPID"
  if [[ -d /proc/self ]]; then
    local d pid cwd
    WU_CWDS="$(for d in /proc/[0-9]*; do
      pid="${d#/proc/}"
      cwd="$(readlink "$d/cwd" 2>/dev/null)" || continue
      printf '%s\t%s\t%s\n' "$pid" "$(cat "$d/comm" 2>/dev/null)" "$cwd"
    done)"
  elif command -v lsof >/dev/null 2>&1; then
    WU_CWDS="$(lsof -nP -a -u "$(id -u)" -d cwd -Fpcn 2>/dev/null |
      awk '/^p/{pid=substr($0,2)} /^c/{cmd=substr($0,2)} /^n/{print pid "\t" cmd "\t" substr($0,2)}')"
  fi
  WU_CWDS="$(awk -F'\t' -v a="$self" -v b="$parent" '$1!=a && $1!=b' <<<"$WU_CWDS")"
}

# Processos com cwd dentro de $1 (caminho real), como "cmd(pid), cmd(pid)".
wu_procs_in() {
  [[ -n "$WU_CWDS" ]] || return 0
  awk -F'\t' -v p="$1" '$3==p || index($3, p "/")==1 {printf "%s%s(%s)", (n++ ? ", " : ""), $2, $1}' <<<"$WU_CWDS"
}

# Caminho real (resolve /tmp -> /private/tmp no macOS, como o lsof reporta).
wu_realpath() { (cd "$1" 2>/dev/null && pwd -P) || printf '%s' "$1"; }

# Worktrees LIGADOS (sem o checkout principal), em TSV:
# caminho<TAB>branch (vazio se detached)<TAB>sha<TAB>locked(0|1)<TAB>prunable(0|1)
wu_worktrees() {
  git worktree list --porcelain | awk -v OFS='\t' '
    function flush() { if (p != "" && n > 1) print p, b, h, l, x; p=""; b=""; h=""; l=0; x=0 }
    /^worktree / { flush(); n++; p=substr($0, 10) }
    /^HEAD /     { h=substr($0, 6) }
    /^branch /   { b=substr($0, 8); sub(/^refs\/heads\//, "", b) }
    /^locked/    { l=1 }
    /^prunable/  { x=1 }
    END          { flush() }'
}

# PR (número) da lista $1 com headRefName == $2 e, se $3 vier, headRefOid == $3.
wu_pr_for() {
  awk -F'\t' -v b="$2" -v s="${3:-}" '$2==b && (s=="" || $3==s) {print $1; exit}' <<<"$1"
}

# Prova de que o SHA $2 da branch $1 já está na base: "ancestor", "squash #N" ou nada.
wu_merge_proof() {
  if git merge-base --is-ancestor "$2" "$WU_BASE" 2>/dev/null; then
    echo ancestor
    return
  fi
  local n
  n="$(wu_pr_for "$WU_MERGED_PRS" "$1" "$2")"
  [[ -n "$n" ]] && echo "squash #$n"
  return 0
}

# Branch recém-criada a partir da default, sem trabalho próprio? Sem esta checagem,
# toda branch nova (ex.: `git worktree add -b feat/x`) passaria na prova "ancestor"
# — o SHA dela é um commit da main — e seria oferecida para limpeza.
# $1 = branch, $2 = SHA. Retorna 0 se for "nova" (não limpar), 1 caso contrário.
wu_is_fresh_branch() {
  local b="$1" sha="$2" n
  # Foi enviada (upstream configurado, mesmo que [gone]): houve trabalho → não é nova.
  [[ -n "$(git for-each-ref --format='%(upstream)' "refs/heads/$b")" ]] && return 1
  # Reflog só com o "branch: Created from…": nunca ganhou commit, reset nem merge.
  n="$(git reflog show --format=%H "refs/heads/$b" 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$n" == 1 ]] && return 0
  # Reflog expirado/vazio: aponta para a ponta da base → acabou de nascer dela.
  [[ "$sha" == "$(git rev-parse "$WU_BASE" 2>/dev/null)" ]] && return 0
  # Sem upstream mas com histórico (merge local nunca enviado): conta como mergeada.
  return 1
}

# Classifica a branch local $1: imprime "status<TAB>motivo<TAB>prova".
wu_classify_branch() {
  local b="$1" sha up track proof n
  sha="$(git rev-parse -q --verify "refs/heads/$b")" || {
    printf 'gone\tbranch não existe mais\t\n'
    return
  }
  up="$(git for-each-ref --format='%(upstream:short)' "refs/heads/$b")"
  track="$(git for-each-ref --format='%(upstream:track)' "refs/heads/$b")"
  proof="$(wu_merge_proof "$b" "$sha")"

  if [[ "$proof" == ancestor ]] && wu_is_fresh_branch "$b" "$sha"; then
    printf 'keep\tbranch nova, sem commits próprios\t\n'
  elif [[ "$proof" == ancestor ]]; then
    printf 'ready\tmergeada (contida em %s)\t%s\n' "$WU_BASE" "$proof"
  elif [[ -n "$proof" ]]; then
    printf 'ready\tmergeada por squash/rebase (PR %s, mesmo SHA)\t%s\n' "${proof#squash }" "$proof"
  elif n="$(wu_pr_for "$WU_MERGED_PRS" "$b")" && [[ -n "$n" ]]; then
    printf 'attention\tPR #%s mergeado, mas a branch tem commits depois dele\t\n' "$n"
  elif n="$(wu_pr_for "$WU_OPEN_PRS" "$b")" && [[ -n "$n" ]]; then
    printf 'keep\tPR #%s aberto\t\n' "$n"
  elif [[ "$track" == *gone* ]]; then
    local why="upstream $up sumiu sem prova de merge"
    [[ "$WU_GH_OK" == 1 ]] || why="$why (gh não consultado)"
    printf 'attention\t%s\t\n' "$why"
  elif [[ "$track" == *ahead* ]]; then
    printf 'keep\tcommits não enviados %s\t\n' "$track"
  elif [[ -z "$up" ]]; then
    printf 'keep\tnão mergeada, sem upstream (nunca enviada)\t\n'
  else
    printf 'keep\tnão mergeada (em andamento)\t\n'
  fi
}

# Classifica um worktree ligado. Recebe a linha TSV do wu_worktrees.
# Imprime "status<TAB>motivo<TAB>prova".
wu_classify_worktree() {
  local path="$1" branch="$2" sha="$3" locked="$4" prunable="$5" real dirty procs
  if [[ "$prunable" == 1 ]]; then
    printf 'ready\tpasta não existe mais (só falta o git worktree prune)\tprunable\n'
    return
  fi
  if [[ "$locked" == 1 ]]; then
    printf 'attention\ttravado (git worktree lock)\t\n'
    return
  fi
  dirty="$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$dirty" -gt 0 ]]; then
    printf 'attention\t%s arquivo(s) modificado(s) ou não rastreado(s)\t\n' "$dirty"
    return
  fi
  real="$(wu_realpath "$path")"
  procs="$(wu_procs_in "$real")"
  if [[ -n "$procs" ]]; then
    printf 'attention\tprocessos rodando dentro dele: %s\t\n' "$procs"
    return
  fi
  if [[ -z "$branch" ]]; then
    if git merge-base --is-ancestor "$sha" "$WU_BASE" 2>/dev/null; then
      printf 'ready\tHEAD destacado, já contido em %s\tancestor\n' "$WU_BASE"
    else
      printf 'attention\tHEAD destacado com commits fora de %s\t\n' "$WU_BASE"
    fi
    return
  fi
  wu_classify_branch "$branch"
}

# Branch do checkout principal, se não for a default (vazio caso contrário).
wu_root_branch() {
  local b
  b="$(git -C "$WU_ROOT" symbolic-ref --short -q HEAD 2>/dev/null)"
  [[ -n "$b" && "$b" != "$WU_DEFAULT" ]] && printf '%s' "$b"
  return 0
}

# Classifica o checkout principal parado numa branch que não é a default.
wu_classify_checkout() {
  local b="$1" res dirty
  res="$(wu_classify_branch "$b")"
  if [[ "${res%%"$TAB"*}" == ready ]]; then
    dirty="$(git -C "$WU_ROOT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$dirty" -gt 0 ]]; then
      printf 'attention\tbranch mergeada, mas o checkout tem %s arquivo(s) modificado(s)\t\n' "$dirty"
      return
    fi
  fi
  printf '%s\n' "$res"
}
