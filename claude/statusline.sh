#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Statusline do Claude Code — tema Tokyo Night (alinhado com starship/wezterm).
#
# O Claude Code chama este script a cada atualização, mandando um JSON pela
# stdin com infos da sessão (modelo, custo, contexto, rate limits...). A gente
# lê esse JSON, monta uma linha colorida e imprime no stdout — o que sair daqui
# vira a barra de status no rodapé da sessão.
#
# Mostra: modelo · custo da sessão (US$) · % da janela de contexto ·
#         % do limite de 5h e de 7 dias (só aparecem em plano Pro/Max) ·
#         gasto do mês vs limite mensal (mesma fonte/cores do status do WezTerm).
# ---------------------------------------------------------------------------

input=$(cat)

# Paleta Tokyo Night (truecolor — o WezTerm suporta).
c_green=$'\033[38;2;158;206;106m'
c_yellow=$'\033[38;2;224;175;104m'
c_orange=$'\033[38;2;255;158;100m'
c_red=$'\033[38;2;247;118;142m'
c_purple=$'\033[38;2;187;154;247m'
c_dim=$'\033[38;2;86;95;137m'
reset=$'\033[0m'

# Sem jq não dá pra parsear o JSON com segurança — degrada com elegância.
if ! command -v jq >/dev/null 2>&1; then
  printf 'Claude (instale jq para o statusline completo)'
  exit 0
fi

# Extrai todos os campos de uma vez (separados por TAB). Campos ausentes viram "".
IFS=$'\t' read -r model cost ctx h5 d7 cwd <<EOF
$(printf '%s' "$input" | jq -r '
  [ .model.display_name // "Claude",
    (.cost.total_cost_usd // 0),
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.workspace.current_dir // .cwd // "")
  ] | @tsv')
EOF

# Cor conforme o nível de uso de um percentual (recebe algo como "73.4").
pct_color() {
  local p=${1%.*} # só a parte inteira
  if [ -z "$p" ]; then printf '%s' "$c_dim"; return; fi
  if   [ "$p" -ge 80 ]; then printf '%s' "$c_red"
  elif [ "$p" -ge 50 ]; then printf '%s' "$c_yellow"
  else                       printf '%s' "$c_green"
  fi
}

# Cor do gasto do mês (mesmas faixas do WezTerm): <60 verde · 60 amarelo ·
# 70 laranja · 85 vermelho. Sem % (sem limite configurado) = verde.
budget_color() {
  local p=$1
  if [ -z "$p" ]; then printf '%s' "$c_green"; return; fi
  if   [ "$p" -ge 85 ]; then printf '%s' "$c_red"
  elif [ "$p" -ge 70 ]; then printf '%s' "$c_orange"
  elif [ "$p" -ge 60 ]; then printf '%s' "$c_yellow"
  else                       printf '%s' "$c_green"
  fi
}

# Segmento de percentual: "<icone> <NN>% <label>" (ou nada, se vazio).
seg_pct() {
  local val=$1 icon=$2 label=$3
  [ -z "$val" ] && return
  local int=${val%.*}
  printf '  %s%s %s%%%s%s %s%s' \
    "$(pct_color "$val")" "$icon" "$int" "$reset" "$c_dim" "$label" "$reset"
}

out="${c_purple}󰚩 ${model}${reset}"
out+="  ${c_green}$(printf '$%.2f' "$cost")${reset}"

# Branch git do diretório da sessão (✓ limpo / ✗ com mudanças não commitadas).
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
      out+="  ${c_yellow} ${branch} ✗${reset}"
    else
      out+="  ${c_dim} ${branch} ✓${reset}"
    fi
  fi
fi

out+="$(seg_pct "$ctx" "󰍛" "ctx")"
out+="$(seg_pct "$h5"  "" "5h")"
out+="$(seg_pct "$d7"  "" "7d")"

# Gasto do mês vs limite — reaproveita o usage.sh (mesma fonte/cache do WezTerm).
script_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
if [ -n "$script_dir" ] && [ -x "$script_dir/usage.sh" ]; then
  month=$("$script_dir/usage.sh" 2>/dev/null)
  if [ -n "$month" ] && [ "$month" != "…" ]; then
    mpct=$(printf '%s' "$month" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
    out+="  $(budget_color "$mpct") ${month}${reset}"
  fi
fi

printf '%s' "$out"
