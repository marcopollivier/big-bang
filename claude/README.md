# claude

Configuração do [Claude Code](https://claude.com/claude-code) e acompanhamento de
consumo de tokens.

## Arquivos

| Arquivo | O que é |
|---|---|
| `settings.json` | **Modelo** das settings do Claude Code (sem nada da empresa), incluindo o modelo padrão (`model`; ver [Modelo padrão](#modelo-padrão)). Seedado para `~/.claude/settings.json` pelo `just seed` — só se não existir. O placeholder `__REPO__` do statusline é trocado pelo caminho real do clone na cópia (por isso, se copiar à mão, troque você mesmo). |
| `statusline.sh` | Statusline **dentro** do Claude Code: `modelo · $custo-sessão · branch✓/✗ · %contexto · %5h · %7d · $mês/$limite`. O gasto do mês reaproveita o `usage.sh` (mesma fonte/cores do WezTerm). Ligado pela chave `statusLine` do `settings.json`. |
| `usage.sh` | Consumo do **mês** vs o limite mensal + gasto de hoje + projeção do fechamento (`$59/$300 · 20% · hoje $9 · proj $295`). Usado pelo statusline e pelo `right_status` do WezTerm. |
| `usage-budget.example` | Modelo do limite mensal. Seedado para `~/.claude/usage-budget` (local, **fora do git**, como o `~/.zshrc.local`). |
| `automode.json` | Contexto do *auto mode* (o que é confiável/sensível para o classificador), válido em **qualquer** máquina e projeto. Aplicado pelo `just automode`. |
| `automode.local.example` | Modelo das entradas de auto mode **só desta máquina** (ex.: org do trabalho, cluster de prod). Seedado para `~/.claude/automode.local.json` (fora do git). |
| `CLAUDE.md` | Instruções **globais** (valem em todo projeto): comunicação, git, código, stack. Symlink → `~/.claude/CLAUDE.md`. |
| `commands/` | Slash commands pessoais (ex.: `/commit-msg`). Symlink → `~/.claude/commands/`. |
| `agents/` | Subagents pessoais: `code-reviewer` (revisão somente leitura do diff) e `test-writer`. Symlink → `~/.claude/agents/`. |
| `skills/<nome>/` | Skills pessoais: `adr` e `wrap-up` (ver [Fechar o trabalho](#fechar-o-trabalho-wrap-up)). **Uma linha por skill** na lista `links` do `justfile` — ver [Symlinks](#symlinks). |
| `output-styles/` | Estilos de resposta (`/output-style`): `Mentor` (explica trade-offs) e `Terse` (mínimo de texto). Symlink → `~/.claude/output-styles/`. |
| `keybindings.json` | Atalhos extras (`ctrl+x m` modelo, `ctrl+x t` thinking, `ctrl+x f` fast, `ctrl+x r` redesenhar) — alternativas aos `meta+…`, que no macOS exigem Option-como-Meta no terminal. Symlink → `~/.claude/keybindings.json`. |
| `hooks.json` + `hooks/` | Hooks (bloqueio de comando perigoso, gitleaks antes do commit, proteção de arquivo de segredo, formatação, notificação). Gravados no settings por `just claude-hooks` — ver [Hooks](#hooks). |
| `mcp.json` | Servidores MCP de user scope, aplicados por `just claude-mcp` — ver [MCP](#mcp). |

## De onde vêm os números

- **`statusline.sh`** lê o JSON que o próprio Claude Code injeta na sessão
  (custo da sessão, % de contexto, % dos limites de 5h/7d — estes só em Pro/Max).
- **`usage.sh`** usa o [`ccusage`](https://github.com/ryoppippi/ccusage) (instalado
  via `mise`: `npm:ccusage` no [`../mise/config.toml`](../mise/config.toml)), que
  soma os logs locais em `~/.claude` e bate com a UI do Claude.

Os dois são **estimativa local**. O saldo/percentual real da conta (ex.: "US$300,
21% usado") é server-side e só aparece no menu da conta — não é exposto por API.
Por isso o limite mensal é configurado à mão em `~/.claude/usage-budget`.

Como o `ccusage` só vê os logs **desta** máquina, o gasto de outras máquinas e
superfícies (claude.ai, desktop, Claude Code na web) não entra. Para compensar,
coloque `offset=<US$>` no `~/.claude/usage-budget`: o valor é somado ao gasto local
(e entra no % e na projeção), e a saída ganha um `~` (`~$97/$600 · 16% · ...`) para
lembrar que tem ajuste manual. Atualize à mão comparando com a interface.

No **WezTerm** o consumo do Claude aparece à direita; à esquerda ficam os recursos
da máquina (`CPU x% · MEM y%`), de [`../wezterm/sysinfo.sh`](../wezterm/sysinfo.sh).

## Setup numa máquina nova

`just seed` cria `~/.claude/settings.json`, `~/.claude/usage-budget` e
`~/.claude/automode.local.json`; o `just automode` grava o auto mode; o `just link`
symlinka `CLAUDE.md`, commands, agents, skills, output styles e keybindings; o
`just claude-hooks` grava os hooks e o `just claude-model`, o modelo padrão (tudo isso
já roda no `just bootstrap`). O MCP é à
parte: `just claude-mcp`, só onde fizer sentido. Depois:

1. Ajuste o limite mensal (US$) em `~/.claude/usage-budget` — varia por máquina
   (trabalho: o limite que te deram; pessoal/Pro: `0` para mostrar só o gasto) e,
   se usar o Claude fora desta máquina, o `offset=` (veja acima).
2. `mise install` garante o `ccusage` (já entra no `just bootstrap`).
3. O statusline aparece em novas sessões do Claude Code; o status do mês aparece
   no WezTerm (recarrega o config sozinho).

## Symlinks

O que não tem segredo nem estado da máquina é **symlinkado** pelo `just link` (lista
`links` no [`justfile`](../justfile)): editar em `~/.claude/...` é editar o repo.

| Repo | Home |
|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/commands/` | `~/.claude/commands/` |
| `claude/agents/` | `~/.claude/agents/` |
| `claude/output-styles/` | `~/.claude/output-styles/` |
| `claude/keybindings.json` | `~/.claude/keybindings.json` |
| `claude/skills/adr/` | `~/.claude/skills/adr/` |
| `claude/skills/wrap-up/` | `~/.claude/skills/wrap-up/` |

**Skills entram uma a uma**: `~/.claude/skills/` pode ter pastas que não são suas
(ex.: `synced/`, gerenciada pela org), então a pasta inteira não vira symlink. Para
adicionar uma skill: crie `claude/skills/<nome>/SKILL.md`, acrescente
`claude/skills/<nome> .claude/skills/<nome>` à lista `links` e rode `just link`.
Commands, agents e output styles novos não precisam disso — a pasta já é o link.

O `CLAUDE.md` global é genérico de propósito (o repo é feito para fork); regra de
um projeto específico vai no `CLAUDE.md` daquele projeto.

## Hooks

`hooks.json` é o bloco `hooks` do settings, com `__REPO__` no lugar do caminho do
clone. O `just claude-hooks` (no `bootstrap`) resolve o caminho e grava **só a chave
`hooks`** do `~/.claude/settings.json` — igual ao `just automode`. O `just doctor`
avisa se divergir. Depois de mexer em `hooks.json`, rode `just claude-hooks`; mexer
só nos scripts (`hooks/*.sh`) já vale na hora.

| Hook | Evento | O que faz |
|---|---|---|
| `block-dangerous.sh` | PreToolUse `Bash` | **Bloqueia** `rm -rf` em `/`, `~`, `$HOME`, `*`, `..`; `sudo`; `git push --force`/`+refspec`/`--mirror`/`--delete` (passa `--force-with-lease`); push para `main`/`master`; commit estando na `main`/`master`; `git reset --hard`, `git clean -f`, `git checkout .`, `git branch -D`; `curl … \| sh`; `chmod -R 777`; `dd of=/dev/…`, `mkfs`, `diskutil erase`; `DROP`/`TRUNCATE`; `cat`/`head`… em arquivo de segredo. |
| `gitleaks-commit.sh` | PreToolUse `Bash` | Em `git commit`, roda `gitleaks git --pre-commit --staged` (e o working tree, se `-a`). Achou segredo: bloqueia e lista `arquivo:linha [regra]` — **nunca o valor**. Sem gitleaks: avisa e deixa passar. |
| `protect-secrets.sh` | PreToolUse `Read\|Edit\|Write\|MultiEdit\|NotebookEdit` | Bloqueia ler/editar `.env*`, `*.pem`/`*.key`/`*.p12`, chaves SSH, `~/.ssh/`, `~/.gnupg/`, `~/.aws/credentials`, `~/.zshrc.local`, `~/.npmrc`, `~/.netrc`, `~/.wakatime.cfg`, `~/.kube/config`… Passam `*.example`, `*.sample`, `*.template`, `*.pub`. |
| `format.sh` | PostToolUse `Edit\|Write\|MultiEdit` | Formata o arquivo editado, se o formatter existir: `goimports`/`gofmt`, `stylua`, `ktlint`, `csharpier`, `shfmt`, `tofu fmt`. Nunca bloqueia. |
| `skills/wrap-up/session-hint.sh` | SessionStart (`startup\|resume\|clear`) | Se o repo da sessão tem worktree/branch já mergeado, mostra **uma linha** sugerindo o `/wrap-up` (inventário offline, < 1s). Só avisa, nunca apaga. Fora de repo git: silêncio. |
| `notify.sh` | Notification, Stop | Notificação do macOS quando o Claude termina ou precisa de você. |

Bloqueio = `exit 2`: o motivo volta para o Claude, que ajusta o plano ou pede para
você rodar à mão (`! <comando>`). Escape para repo onde commit na `main` é normal
(notas, dotfiles pessoais): `export BIG_BANG_ALLOW_MAIN_COMMIT=1` no `~/.zshrc.local`.

> São **rede de segurança, não sandbox**: casam padrões em texto, então dá para
> contornar e há falso positivo (ex.: `sudo` citado dentro de um heredoc). Ajuste as
> regras no topo de cada script. Um erro de sintaxe num hook sai com `exit 2` e
> bloquearia tudo — por isso **rode `claude/hooks/test.sh`** depois de mexer (o CI
> também roda).

## Fechar o trabalho (`/wrap-up`)

Quando o PR é mergeado, sobram worktree, branch local, dev server rodando dentro do
worktree e recursos da stack (daemon do Gradle, emulador, containers). O `/wrap-up`
limpa isso **no repo atual**: inventaria, mostra em 3 blocos (pronto / atenção /
stack), pergunta o que limpar e executa item a item.

| Peça | O que faz |
|---|---|
| `skills/wrap-up/scripts/inventory.sh` | **Só leitura.** Classifica checkout, worktrees, branches, remotas e stashes (TSV). `--quick` = offline, para o hook. |
| `skills/wrap-up/scripts/apply.sh` | Executa **um** item, **revalidando** antes. `git worktree remove` sem `--force`; nunca apaga remoto. |
| `skills/wrap-up/scripts/probes/` | Uma probe por stack (processos órfãos, containers, JVM, mobile, .NET): só sugerem o comando, que roda após OK por item. |
| `skills/wrap-up/test.sh` | Repo descartável + gh falso: merge ff, squash, branch nova, worktree sujo, processo rodando, revalidação. Roda no CI. |

**Quando algo conta como mergeado:** ou o SHA da branch é ancestral de
`origin/<default>` (merge/ff), ou há PR **mergeado** no `gh` com `headRefOid` igual ao
SHA local (squash/rebase: nenhum commit depois do PR). Sem `gh`, vale só a primeira
regra. Branch recém-criada (sem commits próprios) **não** conta, mesmo sendo
ancestral da main.

**Por que o `apply.sh` pode usar `git branch -D`**, se o `block-dangerous` bloqueia o
`-D`? O bloqueio existe porque o `-D` apaga **sem checar merge**. O `-d` do git, por
outro lado, erra para os dois lados: recusa branch squash-mergeada e recusa branch
mergeada quando o HEAD não é a main. O script tenta o `-d` primeiro e só cai no `-D`
**depois de provar o merge** pelas regras acima, e o `test.sh` cobre "não mergeada →
nunca apaga". O hook continua bloqueando o `-D` digitado pelo Claude.

## MCP

Os servidores MCP de user scope ficam no `~/.claude.json`, que o Claude reescreve o
tempo todo — não dá para symlinkar. O `claude/mcp.json` lista os servidores e o
`just claude-mcp` roda `claude mcp add-json --scope user` para os que ainda não
existem (não mexe nos já configurados). Fica **fora do `bootstrap`**, como o `ruflo`.

| Servidor | Tipo | Para quê |
|---|---|---|
| `playwright` | local (`npx @playwright/mcp`) | dirigir um navegador: testar UI, reproduzir bug, tirar screenshot |
| `context7` | remoto (HTTP) | documentação atualizada de bibliotecas/frameworks |

> ⚠️ **Máquina de trabalho:** servidor de terceiro (como o `context7`) recebe trechos
> do que você pergunta — e isso pode incluir código da empresa. Só use se estiver
> aprovado para o caso de uso; senão, remova-o do `mcp.json` no seu fork ou não rode
> o `just claude-mcp` ali. **Nada de token no `mcp.json`**: se um servidor precisar,
> use `${VAR}` e defina a variável no `~/.zshrc.local`.

## Modelo padrão

O modelo padrão fica na chave `model` do [`settings.json`](./settings.json) (ex.:
`"model": "opus"`; aceita alias `opus` | `sonnet` | `haiku` ou o ID completo) — é a
**fonte única**. O `just claude-model` (no `bootstrap`) grava esse valor como
`env.ANTHROPIC_MODEL` no `~/.claude/settings.json`, só essa entrada do `env` (as
outras ficam), e o `just doctor` avisa se divergir. Para trocar o padrão de todas as
máquinas: mude o `model` aqui e rode `just claude-model` em cada uma. Confira numa
sessão nova com `/status`.

**Por que a env, e não só a chave `model`?** Pela [documentação](https://code.claude.com/docs/en/model-config.md)
(Claude Code ≥ 2.1.196), o *organization default* é só um ponto de partida: o
`model` do settings do usuário **ganha** dele. A exceção é quando o admin liga o
**override** do padrão da org. Aí o padrão da org passa a valer mais que o `model`
do settings, o `/model` vale só para a sessão e aparece o aviso *"Your organization's
default (…) applies on restart"* (no `~/.claude.json`, aparece como
`orgModelDefaultCache.override_user_selection: true`). A env `ANTHROPIC_MODEL`
continua ganhando. No bloco `env` do settings ela vale para o Claude aberto por
qualquer caminho (terminal, IDE, cmux), e não só por um shell que leu o `~/.zshrc`.
Sem override, ela só repete o `model`.

Efeito colateral: como a env ganha do `model` que o `/model` grava, o `/model` passa
a valer só para a sessão em **qualquer** máquina. Para um modelo pontual, use o
`/model` ou `claude --model <alias>`; para mudar o padrão, mude o `model` aqui.

> Se a org **restringe** os modelos (`availableModels` em managed settings, ou
> modelo desabilitado no console), nada do lado do usuário contorna. Peça ao admin
> do Claude da org para liberar o modelo.

## Auto mode

O classificador do auto mode **só lê** o bloco `autoMode` do `~/.claude/settings.json`
(e de managed settings): ele **ignora** o `.claude/settings.json` do projeto, de
propósito, para um repo clonado não poder liberar ações para si mesmo. Por isso o
repo guarda o conteúdo em `automode.json`, e o `just automode` (no `bootstrap`)
grava **só a chave `autoMode`** no settings, sem mexer em plugins/prefs:

- `automode.json` — genérico: começa com `"$defaults"` (mantém as regras padrão e
  a confiança no repo em que a sessão abriu) e acrescenta conta do GitHub, onde
  ficam os segredos e as CLIs. `__GH_USER__` vem do remote `origin` e `__REPO__`
  do caminho do clone, então funciona em fork.
- `~/.claude/automode.local.json` — o que é **só desta máquina** (trabalho: org do
  GitHub da empresa, AWS, cluster de prod). Cada lista é concatenada à do repo.
- Regras específicas de um projeto (ex.: "este repo é público", "nada de push na
  `main`") vão no `CLAUDE.md` dele — o classificador também lê o `CLAUDE.md`.

Depois de editar qualquer um dos dois, rode `just automode` e confira com
`claude auto-mode config`. O `just doctor` avisa se o settings divergir.

> ⚠️ Não use o `/auto-mode-setup` para gravar direto: ele gera entradas presas ao
> projeto onde rodou (ex.: "trusted repo: big-bang **only**"), que valem para
> **todos** os projetos. Use-o só como rascunho e copie o que fizer sentido para os
> arquivos acima.

> O `settings.json` é **seedado** (cópia, não symlink) de propósito: ele acumula
> estado por máquina (plugins, prefs), então cada máquina tem o seu. O plugin
> `ruflo` não entra no modelo — é instalado por máquina com `just ruflo`.
