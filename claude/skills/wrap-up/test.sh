#!/usr/bin/env bash
# Testes do wrap-up: monta um repo descartável com origin bare e um gh falso, cria
# cada situação (merge ff, squash, branch nova, worktree sujo, processo rodando…) e
# confere a classificação do inventory.sh e o que o apply.sh faz — e, principalmente,
# que ele NUNCA apaga o que não está provado como mergeado.
# Uso: claude/skills/wrap-up/test.sh   (roda também no CI)
# ok() sempre retorna 0, então `A && ok || ko` nunca roda as duas:
# shellcheck disable=SC2015
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
inv="$here/scripts/inventory.sh"
apply="$here/scripts/apply.sh"
tmp="$(mktemp -d)"
tmp="$(cd "$tmp" && pwd -P)" # caminho real (no macOS /var → /private/var, como o lsof vê)
bg=""
cleanup() {
  [[ -n "$bg" ]] && kill "$bg" 2>/dev/null
  rm -rf "$tmp"
}
trap cleanup EXIT
pass=0 fail=0

# git isolado da config do usuário (assinatura GPG, hooks, templates…)
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$tmp/gitconfig"
git config --global user.name t
git config --global user.email t@t
git config --global commit.gpgsign false
git config --global init.defaultBranch main
git config --global advice.detachedHead false

# gh falso: devolve $FAKE_GH/<state>.json para `gh pr list --state <state> …`
mkdir -p "$tmp/fakegh"
cat >"$tmp/fakegh/gh" <<'EOF'
#!/usr/bin/env bash
state=""
while [[ $# -gt 0 ]]; do [[ "$1" == --state ]] && state="$2"; shift; done
cat "$FAKE_GH/$state.json" 2>/dev/null || echo '[]'
EOF
chmod +x "$tmp/fakegh/gh"
export FAKE_GH="$tmp/fakegh" WRAP_UP_GH="$tmp/fakegh/gh"

ok() { pass=$((pass + 1)); }
ko() { fail=$((fail + 1)) && echo "FAIL $*"; }

# expect <saída do inventory> <kind> <target> <status> [trecho do motivo]
expect() {
  local got
  got="$(awk -F'\t' -v k="$2" -v t="$3" '$1==k && $2==t {print $3 "\t" $4}' <<<"$1")"
  if [[ "${got%%$'\t'*}" == "$4" && "$got" == *"${5:-}"* ]]; then ok; else ko "$2 $3: esperado $4${5:+ ($5)}, veio '${got:-<nada>}'"; fi
}
has_branch() { git -C "$1" rev-parse -q --verify "refs/heads/$2" >/dev/null; }
commit() { # $1 = repo, $2 = arquivo/mensagem
  echo "$2" >"$1/$2" && git -C "$1" add "$2" && git -C "$1" commit -qm "$2"
}

# --- repo base: origin bare + clone em main ---------------------------------------
git init -q --bare "$tmp/origin.git"
git clone -q "$tmp/origin.git" "$tmp/seed" 2>/dev/null
commit "$tmp/seed" init && git -C "$tmp/seed" push -q origin main
git clone -q "$tmp/origin.git" "$tmp/r"
r="$tmp/r"

# merge ff, push e remoto apagado (o caso "PR mergeado + delete branch")
git -C "$r" switch -qc feat/ff && commit "$r" ff && git -C "$r" push -qu origin feat/ff
git -C "$r" switch -q main && git -C "$r" merge -q --ff-only feat/ff && git -C "$r" push -q origin main
git -C "$r" push -q origin --delete feat/ff

# squash: a main ganha um commit DIFERENTE com o mesmo conteúdo; o PR (gh) aponta o SHA local
git -C "$r" switch -qc feat/squash && commit "$r" sq && git -C "$r" push -qu origin feat/squash
squash_sha="$(git -C "$r" rev-parse feat/squash)"
# squash com commit local extra depois do PR
git -C "$r" switch -qc feat/squash-extra && commit "$r" sqx && git -C "$r" push -qu origin feat/squash-extra
sqx_sha="$(git -C "$r" rev-parse feat/squash-extra)"
commit "$r" sqx-depois
git -C "$r" switch -q main
git -C "$r" merge -q --squash feat/squash-extra >/dev/null && git -C "$r" commit -qm "squash sqx"
git -C "$r" push -q origin main
git -C "$r" push -q origin --delete feat/squash feat/squash-extra
printf '[{"number":10,"headRefName":"feat/squash","headRefOid":"%s"},{"number":11,"headRefName":"feat/squash-extra","headRefOid":"%s"}]' \
  "$squash_sha" "$sqx_sha" >"$FAKE_GH/merged.json"

# em andamento: enviada sem PR; e com PR aberto
git -C "$r" switch -qc feat/wip && commit "$r" wip && git -C "$r" push -qu origin feat/wip
git -C "$r" switch -qc feat/open main && commit "$r" open && git -C "$r" push -qu origin feat/open
echo '[{"number":20,"headRefName":"feat/open","headRefOid":"x"}]' >"$FAKE_GH/open.json"
# não mergeada e remoto apagado (sem prova): NUNCA apagar
git -C "$r" switch -qc feat/lost main && commit "$r" lost && git -C "$r" push -qu origin feat/lost
git -C "$r" push -q origin --delete feat/lost
# branch nova, sem commits (ex.: acabou de nascer de `git worktree add -b`)
git -C "$r" branch feat/new main
# mergeada (ff) mas o remoto ainda existe → branch pronta + remota "só listar"
git -C "$r" switch -qc feat/remote-left main && commit "$r" rl && git -C "$r" push -qu origin feat/remote-left
git -C "$r" switch -q main && git -C "$r" merge -q --ff-only feat/remote-left && git -C "$r" push -q origin main
# mergeada, para testar a revalidação do apply
git -C "$r" switch -qc feat/reval && commit "$r" rv && git -C "$r" push -qu origin feat/reval
git -C "$r" switch -q main && git -C "$r" merge -q --ff-only feat/reval && git -C "$r" push -q origin main
git -C "$r" push -q origin --delete feat/reval

# worktrees (em <repo>-worktrees/, para testar o rmdir da pasta-mãe)
wts="$tmp/r-worktrees"
mkdir -p "$wts"
for b in wt-ok wt-dirty wt-proc; do
  git -C "$r" switch -qc "feat/$b" main && commit "$r" "$b" && git -C "$r" push -qu origin "feat/$b"
  git -C "$r" switch -q main && git -C "$r" merge -q --ff-only "feat/$b" && git -C "$r" push -q origin main
  git -C "$r" push -q origin --delete "feat/$b"
  git -C "$r" worktree add -q "$wts/$b" "feat/$b"
done
echo lixo >"$wts/wt-dirty/novo.txt"
(cd "$wts/wt-proc" && exec sleep 300) &
bg=$!
git -C "$r" worktree add -q -b feat/wt-new "$wts/wt-new" main # worktree recém-criado
git -C "$r" stash list >/dev/null
git -C "$r" fetch -q --prune

# --- inventário completo -----------------------------------------------------------
out="$(cd "$r" && "$inv")"
expect "$out" branch feat/ff ready "contida em origin/main"
expect "$out" branch feat/squash ready "PR #10"
expect "$out" branch feat/squash-extra attention "PR #11 mergeado, mas"
expect "$out" branch feat/wip keep
expect "$out" branch feat/open keep "PR #20 aberto"
expect "$out" branch feat/lost attention "sumiu sem prova"
expect "$out" branch feat/new keep "branch nova"
expect "$out" branch feat/remote-left ready
expect "$out" remote origin/feat/remote-left info
expect "$out" worktree "$wts/wt-ok" ready
expect "$out" worktree "$wts/wt-dirty" attention "não rastreado"
expect "$out" worktree "$wts/wt-proc" attention "sleep"
expect "$out" worktree "$wts/wt-new" keep "branch nova"
awk -F'\t' '$1=="branch" && $2 ~ /^feat\/wt-/' <<<"$out" | grep -q . && ko "branch de worktree listada também como branch solta"
grep -q '^stack:processes' <<<"$out" && ok || ko "probe processes não listou o sleep do wt-proc"

# --- modo --quick: offline, sem gh nem processos -----------------------------------
q="$(cd "$r" && "$inv" --quick)"
expect "$q" branch feat/ff ready
expect "$q" branch feat/squash attention "sumiu sem prova"
expect "$q" worktree "$wts/wt-proc" ready # não olha processos: o hook só avisa
grep -q '^stack:' <<<"$q" && ko "--quick rodou probes"

# --- sem gh: squash não é provado, nada a mais é apagado --------------------------
n="$(cd "$r" && WRAP_UP_GH=/nao/existe "$inv")"
expect "$n" branch feat/squash attention "gh não consultado"
expect "$n" meta gh info "gh indisponível"

# --- apply: só apaga o que está pronto --------------------------------------------
cd "$r" || exit 1
for b in feat/wip feat/lost feat/new feat/squash-extra feat/open; do
  "$apply" branch "$b" >/dev/null 2>&1 && ko "apply apagou $b (não mergeada)"
  has_branch "$r" "$b" && ok || ko "$b sumiu"
done
"$apply" branch feat/squash >/dev/null 2>&1 && ok || ko "apply recusou feat/squash (squash provado)"
has_branch "$r" feat/squash && ko "feat/squash não foi apagada" || ok
"$apply" branch feat/ff >/dev/null 2>&1 && ok || ko "apply recusou feat/ff"
"$apply" branch feat/main >/dev/null 2>&1 && ko "apply aceitou branch inexistente"
"$apply" branch main >/dev/null 2>&1 && ko "apply aceitou apagar a default"
"$apply" branch feat/wt-ok >/dev/null 2>&1 && ko "apply apagou branch em uso por worktree"

# revalidação: estava pronta no inventário, ganhou commit depois → recusa
expect "$out" branch feat/reval ready
git -C "$r" switch -q feat/reval && commit "$r" rv2 && git -C "$r" switch -q main
"$apply" branch feat/reval >/dev/null 2>&1 && ko "apply não revalidou feat/reval"
has_branch "$r" feat/reval && ok || ko "feat/reval apagada sem revalidar"

# worktrees
"$apply" worktree "$wts/wt-dirty" >/dev/null 2>&1 && ko "apply removeu worktree sujo"
[[ -f "$wts/wt-dirty/novo.txt" ]] && ok || ko "arquivo do worktree sujo sumiu"
"$apply" worktree "$wts/wt-proc" >/dev/null 2>&1 && ko "apply removeu worktree com processo"
"$apply" worktree "$wts/wt-new" >/dev/null 2>&1 && ko "apply removeu worktree recém-criado"
"$apply" worktree "$wts/wt-ok" >/dev/null 2>&1 && ok || ko "apply recusou wt-ok"
[[ ! -d "$wts/wt-ok" ]] && ok || ko "pasta do wt-ok ficou"
has_branch "$r" feat/wt-ok && ko "branch do wt-ok ficou" || ok
kill "$bg" 2>/dev/null && wait "$bg" 2>/dev/null
bg=""
rm -f "$wts/wt-dirty/novo.txt"
git -C "$r" worktree remove "$wts/wt-new" && git -C "$r" branch -q -d feat/wt-new
# o último apply esvazia <repo>-worktrees/ e tem que removê-la
for b in wt-proc wt-dirty; do "$apply" worktree "$wts/$b" >/dev/null 2>&1 || ko "apply recusou $b depois de limpo"; done
[[ ! -d "$wts" ]] && ok || ko "pasta-mãe vazia $wts não foi removida"

# --- checkout principal parado numa branch mergeada ---------------------------------
git -C "$r" switch -q feat/remote-left
out="$("$inv")"
expect "$out" checkout feat/remote-left ready
"$apply" checkout feat/remote-left >/dev/null 2>&1 && ok || ko "apply recusou o checkout"
[[ "$(git -C "$r" symbolic-ref --short HEAD)" == main ]] && ok || ko "checkout não voltou para a main"
has_branch "$r" feat/remote-left && ko "feat/remote-left não foi apagada" || ok
git -C "$r" ls-remote --exit-code -q origin feat/remote-left >/dev/null && ok || ko "apagou a branch REMOTA"

# --- hook SessionStart -------------------------------------------------------------
hint() { jq -nc --arg d "$1" '{hook_event_name:"SessionStart",source:"startup",cwd:$d}' | "$here/session-hint.sh"; }
git -C "$r" switch -qc feat/ff2 && commit "$r" ff2 && git -C "$r" push -qu origin feat/ff2
git -C "$r" switch -q main && git -C "$r" merge -q --ff-only feat/ff2 && git -C "$r" push -q origin main
git -C "$r" push -q origin --delete feat/ff2 && git -C "$r" branch -q -D feat/reval
h="$(hint "$r")"
[[ "$(jq -r '.hookSpecificOutput.hookEventName' <<<"$h" 2>/dev/null)" == SessionStart ]] && ok || ko "hook: JSON inválido: $h"
[[ "$(jq -r '.systemMessage' <<<"$h" 2>/dev/null)" == *"/wrap-up"* ]] && ok || ko "hook: sem systemMessage"
[[ "$(jq -r '.hookSpecificOutput.additionalContext' <<<"$h")" == *feat/ff2* ]] && ok || ko "hook: contexto sem feat/ff2"
git -C "$r" branch -q -d feat/ff2
[[ -z "$(hint "$r")" ]] && ok || ko "hook falou sem nada pronto"
mkdir -p "$tmp/norepo"
[[ -z "$(hint "$tmp/norepo")" ]] && ok || ko "hook falou fora de repo git"

echo "wrap-up: $pass ok, $fail falha(s)"
[[ $fail -eq 0 ]]
