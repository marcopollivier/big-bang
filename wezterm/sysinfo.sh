#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Recursos da máquina (CPU total e memória) para o left_status do WezTerm.
# Saída: "CPU 6% · MEM 7%"
#
#   - CPU: soma do %cpu de todos os processos / nº de núcleos (uso total, não
#     por core), via `ps` — rápido e sem o atraso de 1s do `top -l 2`.
#   - MEM: pressão de memória (100 - "free percentage" do `memory_pressure`).
#     No macOS a RAM aparece quase sempre "cheia" por causa de cache; este número
#     reflete a PRESSÃO real (baixo = folgado), mais honesto que o Monitor de
#     Atividade.
#
# Cache curto (TTL 4s) + refresh em background, pra não travar a barra.
# ---------------------------------------------------------------------------

cache="${TMPDIR:-/tmp}/wezterm-sysinfo"
ttl=4

refresh() {
  local ncpu cpu mem
  ncpu=$(sysctl -n hw.ncpu 2>/dev/null); [ -z "$ncpu" ] && ncpu=1
  cpu=$(ps -A -o %cpu 2>/dev/null \
    | awk -v n="$ncpu" 'NR > 1 { s += $1 } END { printf "%.0f", (n > 0 ? s / n : s) }')
  mem=$(memory_pressure 2>/dev/null \
    | awk -F: '/free percentage/ { v = $2; gsub(/[^0-9.]/, "", v); printf "%.0f", 100 - v }')
  [ -z "$cpu" ] && cpu=0
  [ -z "$mem" ] && mem=0
  printf 'CPU %s%% · MEM %s%%' "$cpu" "$mem" >"$cache.tmp" 2>/dev/null && mv "$cache.tmp" "$cache"
}

age=999999
[ -f "$cache" ] && age=$(( $(date +%s) - $(stat -f %m "$cache") ))
if [ "$age" -gt "$ttl" ]; then
  refresh >/dev/null 2>&1 &
fi

cat "$cache" 2>/dev/null || printf '…'
