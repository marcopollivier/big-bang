#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Consumo do MÊS atual no Claude Code vs o seu limite mensal de tokens.
#
# Saída (para o status do WezTerm e do Claude Code):
#   com limite configurado:  "$59/$300 · 20% · hoje $9 · proj $295"
#   sem limite:              "$59 mês · hoje $9 · proj $295"
# (proj = projeção do fechamento do mês pelo ritmo atual)
#
# O gasto vem do ccusage (mise: npm:ccusage), que soma os logs locais ~/.claude
# e bate com a UI do Claude — é ESTIMATIVA local. O limite mensal (ex.: US$300 na
# máquina de trabalho) é pessoal e varia por máquina, então fica num arquivo
# LOCAL e NÃO-versionado: ~/.claude/usage-budget (modelo: usage-budget.example).
#
# Cache (TTL 120s) + refresh em background: cada tick do WezTerm só lê um arquivo.
# ---------------------------------------------------------------------------

ccusage_bin="$HOME/.local/share/mise/shims/ccusage"
cache="${TMPDIR:-/tmp}/claude-usage"
budget_file="$HOME/.claude/usage-budget"
ttl=120

# Primeiro número no arquivo de limite (ignora linhas de comentário com #).
read_budget() {
  [ -f "$budget_file" ] || return
  grep -vE '^[[:space:]]*#' "$budget_file" 2>/dev/null \
    | grep -oE '[0-9]+(\.[0-9]+)?' | head -1
}

refresh() {
  local month spend today budget proj dom dim out
  month=$(date +%Y-%m)
  # Gasto do mês.
  spend=$("$ccusage_bin" monthly --json 2>/dev/null \
    | jq -r --arg m "$month" '(.monthly[] | select(.period == $m) | .totalCost) // 0' 2>/dev/null)
  [ -z "$spend" ] && spend=0
  # Gasto de hoje.
  today=$("$ccusage_bin" daily --json --since "$(date +%Y%m%d)" 2>/dev/null \
    | jq -r '[.daily[].modelBreakdowns[].cost] | add // 0' 2>/dev/null)
  [ -z "$today" ] && today=0
  # Projeção do fechamento do mês: gasto/dia-atual * dias-do-mês.
  dom=$(date +%-d)              # dia do mês (1..31)
  dim=$(date -v1d -v+1m -v-1d +%-d) # dias no mês atual
  proj=$(awk -v s="$spend" -v d="$dom" -v t="$dim" 'BEGIN { printf "%.0f", (d > 0 ? s / d * t : s) }')

  budget=$(read_budget)
  if [ -n "$budget" ] && [ "$budget" != "0" ]; then
    out=$(awk -v s="$spend" -v b="$budget" -v h="$today" -v p="$proj" \
      'BEGIN { printf "$%.0f/$%.0f · %.0f%% · hoje $%.0f · proj $%d", s, b, (s / b) * 100, h, p }')
  else
    out=$(awk -v s="$spend" -v h="$today" -v p="$proj" \
      'BEGIN { printf "$%.2f mês · hoje $%.2f · proj $%d", s, h, p }')
  fi
  printf '%s' "$out" >"$cache.tmp" 2>/dev/null && mv "$cache.tmp" "$cache"
}

# Idade do cache em segundos (valor enorme se o arquivo não existir).
age=999999
[ -f "$cache" ] && age=$(( $(date +%s) - $(stat -f %m "$cache") ))

# Cache velho/inexistente → dispara refresh desacoplado (não bloqueia o WezTerm).
if [ "$age" -gt "$ttl" ]; then
  refresh >/dev/null 2>&1 &
fi

# Imprime o valor atual (o anterior enquanto o refresh roda; "…" na 1ª vez).
cat "$cache" 2>/dev/null || printf '…'
