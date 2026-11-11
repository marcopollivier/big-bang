#!/usr/bin/env bash
# PreToolUse (Bash) — bloqueia comandos destrutivos ou arriscados antes de rodarem.
#
# Entrada: o JSON do hook no stdin (.tool_input.command, .cwd).
# Saída:   exit 0 = deixa passar · exit 2 = bloqueia; o stderr volta para o Claude
#          como motivo, para ele ajustar o plano ou pedir que você rode à mão.
# Escape:  BIG_BANG_ALLOW_MAIN_COMMIT=1 libera commit na main/master (repo de notas etc.).
# Testes:  claude/hooks/test.sh
#
# É uma rede de segurança, não um sandbox: casa padrões em texto e pode ser
# contornado. Ajuste as regras abaixo no seu fork.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0 # sem jq não dá para ler a entrada: não bloqueia
input="$(cat)"
cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
cwd="$(jq -r '.cwd // empty' <<<"$input")"
[[ -z "$cmd" ]] && exit 0

block() {
  printf 'BLOQUEADO pelo hook block-dangerous: %s\n' "$1" >&2
  # shellcheck disable=SC2016 # o `!` é literal (prefixo de comando do Claude Code)
  printf 'Se for mesmo intencional, peça ao usuário para rodar à mão (prefixo `!`).\n' >&2
  exit 2
}

# Regras sobre o comando inteiro (ERE, case-insensitive). Formato: regex<TAB>motivo.
rules=''
read -r -d '' rules <<'EOF'
(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|da)?sh([[:space:]]|$)	baixar um script e executar direto (curl|sh)
chmod[[:space:]]+(-[a-z]*R[a-z]*[[:space:]]+)+0?777	chmod -R 777 abre permissão para todo mundo
(^|[[:space:];&|(])mkfs(\.[a-z0-9]+)?[[:space:]]	formatar um sistema de arquivos (mkfs)
(^|[[:space:];&|(])dd[[:space:]].*of=/dev/	dd escrevendo direto num dispositivo
diskutil[[:space:]]+(erase|zero|reformat|partition)	apagar/particionar disco (diskutil)
drop[[:space:]]+(database|schema|table)[[:space:]]	DROP DATABASE/SCHEMA/TABLE apaga dados
(^|[^a-z_])truncate[[:space:]]+(table[[:space:]]+)?[a-z_"`]	TRUNCATE apaga dados
(cat|less|more|head|tail|bat|strings|xxd|base64|open)[[:space:]][^|;&]*(\.zshrc\.local([[:space:]]|$)|\.aws/credentials|\.netrc|\.git-credentials|\.ssh/id_[a-z0-9]+([[:space:]]|$)|\.gnupg/)	ler um arquivo de segredo para o contexto
EOF
while IFS=$'\t' read -r re why; do
  [[ -z "$re" ]] && continue
  if grep -qiE -- "$re" <<<"$cmd"; then block "$why"; fi
done <<<"$rules"

# Regras por trecho: quebra em ; && || | e quebra de linha, e analisa cada comando.
branch=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
  branch="$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null || true)"
fi
on_main=0
[[ "$branch" == main || "$branch" == master ]] && on_main=1

set -f # nada de expansão de glob ao separar palavras (o '*' tem que chegar literal)
nl=$'\n'
segments="${cmd//&&/$nl}"
segments="${segments//||/$nl}"
segments="${segments//;/$nl}"
segments="${segments//|/$nl}"
while IFS= read -r seg; do
  read -ra w <<<"$seg"
  [[ ${#w[@]} -eq 0 ]] && continue
  # tira aspas das palavras e prefixos inofensivos (env VAR=x, time, command, nice…)
  for i in "${!w[@]}"; do w[i]="${w[i]//\"/}"; w[i]="${w[i]//\'/}"; done
  while [[ ${#w[@]} -gt 0 && ("${w[0]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= || "${w[0]}" =~ ^(env|time|command|nice|nohup|exec)$) ]]; do
    w=("${w[@]:1}")
  done
  [[ ${#w[@]} -eq 0 ]] && continue

  [[ "${w[0]}" == sudo ]] && block "sudo (privilégio de root fora do controle do repo)"

  # rm recursivo em alvo catastrófico
  if [[ "${w[0]}" == rm ]]; then
    rec=0
    for a in ${w[@]+"${w[@]:1}"}; do
      [[ "$a" == --recursive || ("$a" =~ ^-[a-zA-Z]+$ && "$a" =~ [rR]) ]] && rec=1
    done
    if [[ $rec -eq 1 ]]; then
      for a in ${w[@]+"${w[@]:1}"}; do
        # shellcheck disable=SC2088 # o ~ é comparado literalmente (o comando ainda não foi expandido)
        case "$a" in
        / | /\* | "~" | "~/" | "~/*" | \$HOME | \$HOME/ | \$HOME/\* | \$\{HOME\} | \$\{HOME\}/ | \$\{HOME\}/\* | \* | . | ./ | .. | ../ | /Users | /Users/ | /System | /Applications | /usr | /etc | /var | /bin | /opt)
          block "rm recursivo em '$a'"
          ;;
        esac
      done
    fi
  fi

  # git: localiza o subcomando pulando opções globais (-C dir, -c k=v, --no-pager…)
  if [[ "${w[0]}" == git ]]; then
    i=1
    while [[ $i -lt ${#w[@]} && "${w[i]}" == -* ]]; do
      [[ "${w[i]}" == -C || "${w[i]}" == -c ]] && i=$((i + 1))
      i=$((i + 1))
    done
    sub="${w[i]:-}"
    args=("${w[@]:$((i + 1))}")
    case "$sub" in
    push)
      for a in ${args[@]+"${args[@]}"}; do
        [[ "$a" == --force || "$a" == -f || ("$a" =~ ^-[a-zA-Z]+$ && "$a" =~ f) ]] &&
          block "git push --force reescreve histórico remoto (use --force-with-lease na sua branch, se precisar)"
        [[ "$a" == --mirror || "$a" == --delete || "$a" == -d ]] && block "git push $a mexe em refs remotas"
        [[ "$a" =~ ^\+ ]] && block "refspec com + é force push"
        [[ "$a" =~ (^|:)(refs/heads/)?(main|master)$ ]] && block "push direto para main/master (abra um PR)"
        [[ $on_main -eq 1 && "$a" == HEAD ]] && block "push de HEAD estando na branch $branch (abra um PR)"
      done
      # `git push` / `git push origin` sem refspec, estando na main
      pos=0
      for a in ${args[@]+"${args[@]}"}; do [[ "$a" != -* ]] && pos=$((pos + 1)); done
      [[ $on_main -eq 1 && $pos -le 1 ]] && block "push estando na branch $branch (abra um PR a partir de uma branch)"
      ;;
    commit)
      [[ $on_main -eq 1 && "${BIG_BANG_ALLOW_MAIN_COMMIT:-0}" != 1 ]] &&
        block "commit direto na $branch — crie uma branch antes (git switch -c <tipo>/<assunto>)"
      ;;
    reset)
      for a in ${args[@]+"${args[@]}"}; do
        [[ "$a" == --hard ]] && block "git reset --hard descarta trabalho não commitado (use git stash)"
      done
      ;;
    clean)
      for a in ${args[@]+"${args[@]}"}; do
        [[ "$a" == --force || ("$a" =~ ^-[a-zA-Z]+$ && "$a" =~ f) ]] &&
          block "git clean -f apaga arquivos não versionados (rode git clean -n para ver o que sairia)"
      done
      ;;
    checkout | restore)
      for a in ${args[@]+"${args[@]}"}; do
        [[ "$a" == . || "$a" == ./ || "$a" == :/ ]] && block "git $sub $a descarta todas as mudanças locais"
      done
      ;;
    branch)
      for a in ${args[@]+"${args[@]}"}; do
        [[ "$a" == -D ]] && block "git branch -D apaga branch sem checar merge (use -d)"
      done
      ;;
    esac
  fi
done <<<"$segments"

exit 0
