# shellcheck shell=bash
# Comum às probes de stack. Contrato de cada probe: `probe.sh <raiz-do-repo>`,
# SÓ LEITURA, sai em silêncio se a stack não existir no repo, e imprime linhas TSV
#   stack:<nome><TAB>alvo<TAB>info<TAB>motivo<TAB>comando sugerido
# O comando só roda com o OK do usuário, item a item (recurso da máquina pode estar
# em uso por outro projeto).

row() { printf 'stack:%s\t%s\tinfo\t%s\t%s\n' "$@"; }

# Existe algum arquivo com um destes nomes (glob) até 3 níveis abaixo de $1?
has_file() {
  local root="$1" args=() n
  shift
  for n in "$@"; do args+=(-o -name "$n"); done
  [[ -n "$(find "$root" -maxdepth 3 \( -path '*/node_modules' -o -path '*/.git' -o -path '*/build' \) -prune \
    -o \( "${args[@]:1}" \) -print -quit 2>/dev/null)" ]]
}

# PIDs (separados por espaço) cujo comando casa com o padrão do pgrep -f
pids() { pgrep -f "$1" 2>/dev/null | tr '\n' ' ' | sed 's/ $//'; }
