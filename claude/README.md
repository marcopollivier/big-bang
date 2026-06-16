# claude

Configuração do [Claude Code](https://claude.com/claude-code) e acompanhamento de
consumo de tokens.

## Arquivos

| Arquivo | O que é |
|---|---|
| `settings.json` | **Modelo** das settings do Claude Code (sem nada da empresa). Seedado para `~/.claude/settings.json` pelo `just seed` — só se não existir. |
| `statusline.sh` | Statusline **dentro** do Claude Code: `modelo · $custo-sessão · branch✓/✗ · %contexto · %5h · %7d · $mês/$limite`. O gasto do mês reaproveita o `usage.sh` (mesma fonte/cores do WezTerm). Ligado pela chave `statusLine` do `settings.json`. |
| `usage.sh` | Consumo do **mês** vs o limite mensal + gasto de hoje + projeção do fechamento (`$59/$300 · 20% · hoje $9 · proj $295`). Usado pelo statusline e pelo `right_status` do WezTerm. |
| `usage-budget.example` | Modelo do limite mensal. Seedado para `~/.claude/usage-budget` (local, **fora do git**, como o `~/.zshrc.local`). |

## De onde vêm os números

- **`statusline.sh`** lê o JSON que o próprio Claude Code injeta na sessão
  (custo da sessão, % de contexto, % dos limites de 5h/7d — estes só em Pro/Max).
- **`usage.sh`** usa o [`ccusage`](https://github.com/ryoppippi/ccusage) (instalado
  via `mise`: `npm:ccusage` no [`../mise/config.toml`](../mise/config.toml)), que
  soma os logs locais em `~/.claude` e bate com a UI do Claude.

Os dois são **estimativa local**. O saldo/percentual real da conta (ex.: "US$300,
21% usado") é server-side e só aparece no menu da conta — não é exposto por API.
Por isso o limite mensal é configurado à mão em `~/.claude/usage-budget`.

No **WezTerm** o consumo do Claude aparece à direita; à esquerda ficam os recursos
da máquina (`CPU x% · MEM y%`), de [`../wezterm/sysinfo.sh`](../wezterm/sysinfo.sh).

## Setup numa máquina nova

`just seed` cria `~/.claude/settings.json` e `~/.claude/usage-budget`. Depois:

1. Ajuste o limite mensal (US$) em `~/.claude/usage-budget` — varia por máquina
   (trabalho: o limite que te deram; pessoal/Pro: `0` para mostrar só o gasto).
2. `mise install` garante o `ccusage` (já entra no `just bootstrap`).
3. O statusline aparece em novas sessões do Claude Code; o status do mês aparece
   no WezTerm (recarrega o config sozinho).

> O `settings.json` é **seedado** (cópia, não symlink) de propósito: ele acumula
> estado por máquina (plugins, prefs), então cada máquina tem o seu. O plugin
> `ruflo` não entra no modelo — é instalado por máquina com `just ruflo`.
