# Setup do Neovim como IDE — registro completo

> Documento gerado a partir da sessão de configuração de **2026-06-11**.
> Objetivo: transformar o Neovim numa IDE para **Go**, **.NET/C#** e **Kotlin**,
> com integração ao **Claude Code** e ao **WakaTime**, usando **mise** como
> gerenciador de versões. Máquina: macOS (Apple Silicon), shell **zsh**.

---

## 1. Diagnóstico inicial (ponto de partida)

| Item | Estado encontrado |
|---|---|
| Vim | 9.1 instalado, **sem nenhuma config** (`~/.vimrc`/`~/.vim` não existiam) |
| Neovim | não instalado |
| Homebrew | instalado (6.0.0) em `/opt/homebrew`, mas **fora do PATH** |
| Toolchains | nenhum (sem Go, .NET, Kotlin, Java, Node) |
| Shell | zsh com oh-my-zsh (tema robbyrussell, plugin `git`) |
| Claude CLI | já instalado em `~/.local/bin/claude` |
| WakaTime | não configurado |
| Xcode CLT | presente (`cc`/`clang`/`make` disponíveis → treesitter compila) |

## 2. Decisões tomadas

- **Editor:** migrar para **Neovim** (mantendo o Vim 9.1 intacto).
- **Gerenciador de versões:** **mise** (substitui asdf/sdkman; um só pra todas as linguagens).
- **Linguagens:** Go, .NET/C# e Kotlin (todas).
- **Plugins:** config Lua modular com **lazy.nvim** (sem distro pronta tipo LazyVim).
- **C#:** **omnisharp** (mais maduro). Alternativa futura: `roslyn.nvim` se houver problemas com .NET 10.
- **Integração Claude:** `coder/claudecode.nvim` (integração IDE: o Claude enxerga
  seleção/arquivo e abre diffs no Neovim) + `snacks.nvim` como terminal.

---

## 3. O que foi instalado

### 3.1 Fundação do shell
- **`~/.zprofile`** (criado): `eval "$(/opt/homebrew/bin/brew shellenv)"` → Homebrew no PATH.
- **`~/.zshrc`** (editado, ao fim do arquivo): fallback do brew + ativação do mise:
  ```sh
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
  if command -v mise >/dev/null 2>&1; then eval "$(mise activate zsh)"; fi
  ```

### 3.2 Ferramentas base (Homebrew)
`mise`, `neovim` (0.12.3), `ripgrep`, `fd`.

### 3.3 Toolchains (mise) — em `~/.config/mise/config.toml`
| Linguagem | Versão | Comando usado |
|---|---|---|
| Go | 1.26.4 | `mise use -g go@latest` |
| Java (Temurin) | 21.0.11 LTS | `mise use -g java@temurin-21` |
| Node | 24.16.0 | `mise use -g node@lts` |
| Kotlin | 2.4.0 | `mise use -g kotlin@latest` |
| .NET SDK | 10.0.301 | `mise use -g dotnet@latest` |

### 3.4 Servidores/ferramentas (Mason) — instalados e pré-compilados
LSP: `gopls`, `omnisharp`, `kotlin-language-server`, `lua-language-server`.
Formatadores: `gofumpt`, `goimports`, `csharpier`, `ktlint`, `stylua`.
Debug: `delve` (Go), `netcoredbg` (C#/.NET), `kotlin-debug-adapter` (Kotlin).

### 3.5 Parsers do Treesitter (19)
go, gomod, gosum, gowork, c_sharp, kotlin, lua, vim, vimdoc, json, yaml, toml,
markdown, markdown_inline, bash, gitignore, gitcommit, dockerfile, sql.

---

## 4. Estrutura da config do Neovim (`~/.config/nvim/`)

```
init.lua                      -- define <leader>=Espaço e carrega os módulos
lua/config/options.lua        -- opções do editor (número, clipboard, undo, etc.)
lua/config/keymaps.lua        -- atalhos gerais (janelas, salvar, diagnósticos)
lua/config/lazy.lua           -- bootstrap do lazy.nvim
lua/plugins/colorscheme.lua   -- tokyonight (night)
lua/plugins/treesitter.lua    -- nvim-treesitter (branch master) — syntax/indent
lua/plugins/telescope.lua     -- busca de arquivos/grep/símbolos (+fzf-native)
lua/plugins/editor.lua        -- neo-tree, lualine, gitsigns, which-key, autopairs, Comment, indent
lua/plugins/completion.lua    -- nvim-cmp + LuaSnip + sources
lua/plugins/lsp.lua           -- Mason + mason-tool-installer + nvim-lspconfig (API nativa 0.11+)
lua/plugins/formatting.lua    -- conform.nvim (formata ao salvar)
lua/plugins/dap.lua           -- nvim-dap + dap-ui + debug de Go/C#/Kotlin
lua/plugins/claude.lua        -- claudecode.nvim + snacks.nvim (terminal)
lua/plugins/wakatime.lua      -- vim-wakatime
README.md                     -- cheatsheet de atalhos
SETUP.md                      -- este documento
```

Detalhe importante de implementação: o `lsp.lua` usa a **API nativa de LSP do
Neovim 0.11+** (`vim.lsp.config()` / `vim.lsp.enable()`), que lê os specs de
`nvim-lspconfig/lsp/<servidor>.lua`. **Não sobrescrevemos o `cmd`** dos
servidores — o binário do Mason é resolvido via PATH e os argumentos
obrigatórios vêm do próprio spec.

---

## 5. Problemas encontrados e como foram resolvidos

1. **Homebrew "invisível"** — estava instalado mas fora do PATH.
   *Solução:* `brew shellenv` no `~/.zprofile`.

2. **`nvim-treesitter` quebrando** (`module 'nvim-treesitter.configs' not found`).
   *Causa:* a branch padrão virou `main` (reescrita incompatível).
   *Solução:* fixar `branch = "master"` em `treesitter.lua`.

3. **Omnisharp (C#) não anexava.**
   *Causa 1 (bug nosso):* sobrescrevemos o `cmd` do omnisharp só com o caminho do
   binário, descartando os flags obrigatórios (`-z --hostPID … --languageserver`).
   *Solução:* remover o override de `cmd` e deixar o spec do lspconfig cuidar disso.
   *Causa 2 (ambiente):* ao abrir um `.cs` a partir da home, o omnisharp varria a
   home e batia no loop de symlink do mise (ver item 6). Resolvido na prática
   abrindo o nvim de dentro do projeto.

4. **Kotlin LSP não "anexava" em arquivo solto.**
   *Causa:* o `kotlin-language-server` exige raiz de projeto
   (`build.gradle`/`settings.gradle`/`pom.xml`). Não é bug — comportamento esperado.

---

## 6. Nota: symlink do mise (alarme falso)

Existe um symlink em:

```
~/.local/state/mise/trusted-configs/Users-U004334-4bb99e5cee51aebc  →  /Users/U004334
```

Durante a sessão isso foi inicialmente sinalizado como "loop recursivo a corrigir",
mas é **estado normal do trust-store do mise** (ele registra diretórios de config
confiados usando symlinks). **Não deve ser removido** — o mise apenas o recriaria.
Foi o que fez o globber do omnisharp tropeçar quando o nvim era aberto *a partir
da home*, mas no uso real (nvim aberto de dentro do projeto) nada varre a home.

> Decisão: **deixar como está.**

---

## 7. Como usar (passo a passo)

1. **Abra um terminal novo** (pra carregar mise/brew) ou rode `source ~/.zshrc`.
2. Rode **`nvim`** já **dentro da pasta do projeto**.
3. **WakaTime (uma vez):** dentro do nvim, `:WakaTimeApiKey` e cole a chave de
   <https://wakatime.com/settings/api-key> (fica salva em `~/.wakatime.cfg`).
4. Abra um `.go`, `.cs` ou `.kt` — o LSP anexa sozinho.
   - **C#:** abra a partir da raiz do projeto; omnisharp leva ~10-30s no 1º start.
   - **Kotlin:** precisa de projeto Gradle/Maven pra subir o LSP.

`<leader>` = **Espaço**. Segure-o para o which-key mostrar os atalhos.

### Atalhos essenciais
| Atalho | Ação |
|---|---|
| `<leader>ff` / `<leader><leader>` | Buscar arquivos |
| `<leader>fg` | Grep no projeto |
| `<leader>n` | Árvore de arquivos |
| `gd` / `gr` / `K` | Definição / Referências / Hover |
| `<leader>rn` / `<leader>ca` | Renomear / Code action |
| `<leader>cf` | Formatar (também roda ao salvar) |
| `[d` / `]d` | Diagnóstico anterior / próximo |
| `<leader>db` / `<leader>dc` / `<leader>dt` | Breakpoint / Continuar / UI de debug |
| `<leader>ac` | Abrir/fechar Claude |
| `<leader>as` (visual) | Enviar seleção ao Claude |
| `<leader>aa` / `<leader>ax` | Aceitar / recusar diff do Claude |
| `<C-/>` | Terminal |

*(Cheatsheet completo em `README.md`.)*

---

## 8. Manutenção

- `:Lazy` — plugins (atualizar com `U`, sincronizar com `S`).
- `:Mason` — LSPs/formatadores/debuggers.
- `mise upgrade` — atualizar toolchains; `mise use -g <lang>@<versão>` para fixar versão.
- `:checkhealth` — diagnóstico do Neovim.
- `:TSUpdate` — atualizar parsers do treesitter.

## 9. Extras já aplicados

- **Debug nas 3 linguagens:** Go (delve), C# (netcoredbg), Kotlin (kotlin-debug-adapter).
  - C#: `<leader>dc` pede o caminho da DLL (ex.: `bin/Debug/<target>/App.dll`).
  - Kotlin: `<leader>dc` pede a `mainClass` (ex.: `MainKt`).
- **Editor padrão:** no `~/.zshrc` foram adicionados `export EDITOR=nvim`,
  `export VISUAL=nvim`, e os aliases `vim=nvim` e `vi=nvim`.

## 10. Ideias / próximos passos (não feitos)

- Trocar omnisharp por **`roslyn.nvim`** se o C# der problema com .NET 10.
