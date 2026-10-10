# cmux

[cmux](https://cmux.com) (`com.cmuxterm.app`) instalado em `/Applications/cmux.app`
pelo [`Brewfile`](../Brewfile) (`cask "cmux"`). Em teste como alternativa ao WezTerm.

> Já tinha o app instalado à mão (DMG)? Faça o brew adotá-lo **antes** do
> `just brew`, senão o `brew bundle` falha com "app já existe":
> `brew install --cask --adopt cmux` (em Mac gerenciado pede senha — rode no
> seu terminal). Confira a versão com `cmux --version` (este setup foi validado
> em 0.64.22; o beta de Extensions e o wrapper do Claude são recentes).

> **Importante — o que o cmux *é*:** ele **não é um terminal genérico** como o
> WezTerm. É um **orquestrador de agentes de IA de código**: roda vários agentes
> (Claude Code, Codex, Gemini, opencode…) **em paralelo**, cada um num workspace
> isolado (git worktree / VM), com sidebar de workspaces, diff viewer, browser
> embutido e integração com PRs. O terminal é renderizado com o **Ghostty**
> embutido — então dá pra usar como terminal com splits/abas, mas esse é só um
> pedaço do que ele faz. Veja ["Potencial"](#potencial).

## Como a config funciona (camadas)

| Camada | Arquivo (symlink via `just link`) | Controla |
|---|---|---|
| **Ghostty** | `cmux/ghostty.config` → `~/.config/ghostty/config` | Aparência/comportamento **do terminal**: fonte, tema, transparência, blur, cursor, copy-on-select, scrollback, atalhos do terminal (limpar, fonte) |
| **cmux** | `cmux/cmux.json` → `~/.config/cmux/cmux.json` | Atalhos de **janela/split/foco**, abas, comportamento do app |

Recarregar as duas sem reiniciar o app: `cmux reload-config` (ou **CMD+Shift+,**).
Validar: `cmux config validate` / `cmux config doctor`. O `just link` faz backup do
`cmux.json` real em `.bak`.

> ⚠ **O cmux já sobrescreveu o symlink do `cmux.json`** com um template dele
> (aconteceu duas vezes em updates do app). Sintoma: os atalhos abaixo "voltam ao
> padrão" e `cmux config doctor` lista só `$schema, automation, schemaVersion`.
> `just doctor` acusa `NOT A SYMLINK` — basta rodar `just link` de novo.

Há uma **terceira camada** que **não cabe em arquivo**: toggles de beta ficam só
na UI de Settings (UserDefaults do app). É o caso do botão de plugins — a receita
`just cmux-settings` grava isso por você (ver [checklist](#replicar-em-outra-máquina-checklist)).

## Atalhos (espelhando o WezTerm)

| Ação | WezTerm | cmux (após este config) |
|---|---|---|
| Split embaixo | `CMD+Enter` | `CMD+Enter` |
| Split à direita | `CMD+Shift+Enter` | `CMD+Shift+Enter` |
| Split à esquerda | `CMD+Alt+Enter` | — (cmux só divide direita/baixo) |
| Mover foco entre panes | `CMD+setas` | `CMD+setas` |
| Zoom no pane | `CMD+Shift+Z` | `CMD+Shift+Z` |
| Modo de cópia | `CMD+Shift+X` | `CMD+Shift+X` |
| Fechar pane/aba | `CMD+W` | `CMD+W` |
| Paleta de comandos | `CMD+Shift+P` | `CMD+Shift+P` |
| Limpar terminal | `CMD+K` | `CMD+K` (via Ghostty) |
| Fonte +/-/0 | `CMD +/-/0` | `CMD +/-/0` (via Ghostty) |
| Nova aba / surface | — | `CMD+N` / `CMD+T` |
| Equalizar splits | `CMD+Ctrl+setas` (resize) | `CMD+Shift+Ctrl+=` (resize por arrasto) |

### Diferenças que ficam (não têm equivalente 1:1)
- **Sem "split à esquerda".** O canvas do cmux só divide para a direita/baixo.
- **Resize de pane por teclado** (o `CMD+Ctrl+setas` do wezterm) não existe — no
  cmux se redimensiona arrastando a borda, ou `CMD+Shift+Ctrl+=` para equalizar.
- Dim de panes inativos: o wezterm escurece; aqui não há equivalente direto.

## Links: browser embutido × navegador do sistema

Não há escolha por clique (nenhum modificador documentado). A regra fica no
bloco `browser` do `cmux.json`, por destino:

- `hostsToOpenInEmbeddedBrowser` — ficam no browser do cmux (aqui: localhost/dev).
- `urlsToAlwaysOpenExternally` — vão sempre pro navegador do sistema (aqui:
  GitHub, Jira/Atlassian).
- `openTerminalLinksInCmuxBrowser: false` manda **todos** os links do terminal
  pro sistema; `interceptTerminalOpenCommandInCmuxBrowser` faz o `open https://…`
  seguir as mesmas regras.

## Replicar em outra máquina (checklist)

O que faz o cmux "funcionar igual" está espalhado em **três lugares**; só o
primeiro é o repo. Siga na ordem:

1. **Versão.** `just brew` (ou `brew install --cask cmux`; `--adopt` se o app já
   existia). `cmux --version` deve ser ≥ 0.64.
2. **Arquivos do repo.** `just link` e depois `just doctor`: as duas linhas
   `~/.config/ghostty/config` e `~/.config/cmux/cmux.json` têm de aparecer como
   `ok … ->`. `cmux config doctor` deve listar `app, automation, browser, shortcuts, terminal`.
3. **Settings só da UI** (não têm chave no `cmux.json`):
   - **Extensions (beta)** — é o **botão de plugins** na sidebar. Rode
     `just cmux-settings` (grava o UserDefaults) e reabra o app; ou ligue nas
     Settings. Confira com
     `defaults read com.cmuxterm.app extensions.beta.enabled` → `1`
     (o `just doctor` também mostra).
   - **Automation › Claude Code Integration** e **Terminal › Resume Agent
     Sessions on Reopen**: o `cmux.json` do repo já força os dois como `true`;
     só confira que a UI reflete.
4. **Sessão do Claude sobreviver ao fechar/reabrir.** O cmux envolve o `claude`
   num *wrapper* que injeta hooks: cada sessão grava seu id em
   `~/.cmuxterm/claude-hook-sessions.json` e, ao reabrir o app, o cmux roda
   `claude --resume <id>` em cada pane. Para isso funcionar:
   - abra o `claude` **de um shell do cmux** — dentro dele, `type claude` tem de
     mostrar `…/cmux-cli-shims/<id>/claude` (a função `claude()` que o cmux define
     no `.zshenv`, antes do seu `.zshrc`);
   - **não tenha `alias claude=…`** no `~/.zshrc`/`~/.zshrc.local`: alias ganha da
     função e pula o wrapper (sem hooks, sem resume). Mesma coisa para `exec` de
     outro shell/tmux no `.zshrc`;
   - feche o app normalmente (Cmd+Q); kill/force-quit não salva a sessão.

**Diagnóstico rápido** (rode dentro de um terminal do cmux):

```sh
cmux --version                                     # versão do app
cmux config doctor                                 # cmux.json ativo e suas chaves
just doctor                                        # symlinks (cmux.json é o que o app sobrescreve)
type -a claude                                     # 1ª linha deve ser o shim do cmux
defaults read com.cmuxterm.app extensions.beta.enabled   # 1 = botão de plugins
ls -la ~/.cmuxterm/claude-hook-sessions.json       # sessões registradas p/ resume
```

Sintoma → causa provável: *sem botão de plugins* → Extensions (beta) desligado
ou versão antiga; *abas voltam mas o Claude não* → `claude` não passou pelo
wrapper (alias/PATH), integração desligada, ou versão antiga do cmux.

## Potencial

O ganho real do cmux **não** é ser um terminal melhor — é o que vem por cima dele:

1. **Paralelismo de agentes.** Disparar N agentes (Claude Code etc.) em workspaces
   isolados ao mesmo tempo e revisar os diffs lado a lado — sem misturar contexto
   nem pisar no mesmo working tree. Forte pra "tenta 3 abordagens e eu escolho".
2. **Isolamento por workspace.** Cada agente roda em seu git worktree / VM, com
   branch e diretório próprios — combina com a regra "uma branch por escopo".
3. **Diff viewer + PR integrados.** Revisar mudanças (`cmux diff`), abrir/clicar PRs
   pela sidebar, ver status de git/portas por workspace.
4. **Browser embutido + canvas.** Terminal, browser e markdown como "surfaces" no
   mesmo canvas — útil pra acompanhar app rodando ao lado do agente.
5. **Controle via socket/CLI.** `cmux <path>`, `cmux open`, `cmux diff`, `cmux rpc`,
   hooks por agente — dá pra automatizar/scriptar o fluxo (inclusive a partir daqui).
6. **Hooks de notificação.** Avisa quando um agente termina/precisa de input — bom
   pra tocar vários em paralelo sem ficar olhando.

Comandos úteis pra explorar: `cmux docs agents`, `cmux docs settings`,
`cmux docs shortcuts`, `cmux capabilities`, `cmux welcome`.
