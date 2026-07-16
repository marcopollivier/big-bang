# cmux

[cmux](https://cmux.com) (`com.cmuxterm.app`) instalado em `/Applications/cmux.app`.
Em teste como alternativa ao WezTerm.

> **Importante — o que o cmux *é*:** ele **não é um terminal genérico** como o
> WezTerm. É um **orquestrador de agentes de IA de código**: roda vários agentes
> (Claude Code, Codex, Gemini, opencode…) **em paralelo**, cada um num workspace
> isolado (git worktree / VM), com sidebar de workspaces, diff viewer, browser
> embutido e integração com PRs. O terminal é renderizado com o **Ghostty**
> embutido — então dá pra usar como terminal com splits/abas, mas esse é só um
> pedaço do que ele faz. Veja ["Potencial"](#potencial).

## Como a config funciona (duas camadas)

| Camada | Arquivo (symlink via `just link`) | Controla |
|---|---|---|
| **Ghostty** | `cmux/ghostty.config` → `~/.config/ghostty/config` | Aparência/comportamento **do terminal**: fonte, tema, transparência, blur, cursor, copy-on-select, scrollback, atalhos do terminal (limpar, fonte) |
| **cmux** | `cmux/cmux.json` → `~/.config/cmux/cmux.json` | Atalhos de **janela/split/foco**, abas, comportamento do app |

Recarregar as duas sem reiniciar o app: `cmux reload-config` (ou **CMD+Shift+,**).
Validar: `cmux config validate`. O `just link` faz backup do `cmux.json` real em `.bak`.

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
| Equalizar splits | `CMD+Ctrl+setas` (resize) | `CMD+Ctrl+=` (resize por arrasto) |

### Diferenças que ficam (não têm equivalente 1:1)
- **Sem "split à esquerda".** O canvas do cmux só divide para a direita/baixo.
- **Resize de pane por teclado** (o `CMD+Ctrl+setas` do wezterm) não existe — no
  cmux se redimensiona arrastando a borda, ou `CMD+Ctrl+=` para equalizar.
- Dim de panes inativos: o wezterm escurece; aqui não há equivalente direto.

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
