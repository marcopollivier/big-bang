# Neovim IDE — referência rápida

Config de Neovim como IDE para **Go**, **.NET/C#** e **Kotlin**, com integração
ao **Claude Code** e **WakaTime**. Histórico completo e racional em [`SETUP.md`](./SETUP.md).

## Instalação nesta máquina

Pré-requisitos: Neovim ≥ 0.11, `git`, `ripgrep`, `fd`, um compilador C (Xcode CLT no macOS)
e os toolchains via **mise** (`go`, `java`, `kotlin`, `node`, `dotnet`). Passo a passo em `SETUP.md`.

```sh
just link    # symlinka ~/.config/nvim para esta pasta (entre os demais configs)
# fallback manual:  ln -sfn "$(pwd)/nvim" ~/.config/nvim
```

No primeiro `nvim`, o **lazy.nvim** instala os plugins e o **Mason** instala os
LSPs/formatadores/debuggers automaticamente. Versões dos plugins ficam fixadas em `lazy-lock.json`.

---

`<leader>` = **Espaço**. Pressione `<leader>` e espere: o **which-key** mostra o que está disponível.

## Linguagens configuradas
| Linguagem | LSP | Formatador | Debug |
|---|---|---|---|
| Go | gopls | goimports + gofumpt | delve (nvim-dap-go) |
| C# / .NET | omnisharp | csharpier | netcoredbg |
| Kotlin | kotlin-language-server | ktlint | kotlin-debug-adapter |
| Lua | lua-language-server | stylua | — |

Toolchains gerenciados pelo **mise** (`~/.config/mise/config.toml`). Servidores/ferramentas pelo **Mason** (`:Mason`).

## Navegação / busca (Telescope)
| Atalho | Ação |
|---|---|
| `<leader>ff` / `<leader><leader>` | Buscar arquivos |
| `<leader>fg` | Grep no projeto |
| `<leader>fb` | Buffers abertos |
| `<leader>fr` | Arquivos recentes |
| `<leader>fw` | Buscar palavra sob o cursor |
| `<leader>fd` | Diagnósticos do projeto |
| `<leader>n` | Árvore de arquivos (neo-tree) |

## LSP (dentro de um arquivo de código)
| Atalho | Ação |
|---|---|
| `gd` / `gr` / `gI` | Definição / Referências / Implementações |
| `K` | Documentação (hover) |
| `<leader>rn` | Renomear símbolo |
| `<leader>ca` | Code action |
| `<leader>cf` | Formatar (também roda ao salvar) |
| `<leader>ds` | Símbolos do documento |
| `[d` / `]d` | Diagnóstico anterior / próximo |
| `<leader>e` | Mostrar diagnóstico da linha |
| `<leader>th` | Alternar inlay hints |

## Debug (nvim-dap)
| Atalho | Ação |
|---|---|
| `<leader>db` | Breakpoint |
| `<leader>dc` | Continuar / iniciar |
| `<leader>do` / `<leader>di` / `<leader>dO` | Step over / into / out |
| `<leader>dt` | Alternar UI de debug |

> **C#:** ao iniciar (`<leader>dc`), informe o caminho da DLL (ex.: `bin/Debug/net10.0/App.dll`) — rode `dotnet build` antes.
> **Kotlin:** ao iniciar, informe a `mainClass` (ex.: `MainKt`). Requer projeto Gradle/Maven.

## Claude Code (integração IDE)
| Atalho | Ação |
|---|---|
| `<leader>ac` | Abrir / fechar o Claude |
| `<leader>af` | Focar no painel do Claude |
| `<leader>ar` | Retomar sessão (`--resume`) |
| `<leader>aC` | Continuar última sessão (`--continue`) |
| `<leader>ab` | Adicionar o buffer atual ao contexto |
| `<leader>as` (visual) | Enviar a seleção ao Claude |
| `<leader>as` (na árvore) | Adicionar o arquivo selecionado |
| `<leader>aa` / `<leader>ax` | Aceitar / recusar o diff proposto |

O Claude enxerga sua seleção e o arquivo atual, e abre os diffs como buffers do Neovim.

## Terminal
| Atalho | Ação |
|---|---|
| `<C-/>` | Abrir/fechar terminal (snacks) |
| `<Esc><Esc>` | Sair do modo terminal |

## WakaTime
Na primeira vez que abrir um arquivo, rode `:WakaTimeApiKey` e cole sua chave
(https://wakatime.com/settings/api-key). Fica salva em `~/.wakatime.cfg`.

## Manutenção
- `:Lazy` — gerenciar plugins (update com `U`, sync com `S`)
- `:Mason` — gerenciar LSPs/formatadores/debuggers
- `:checkhealth` — diagnóstico do Neovim
- `:TSUpdate` — atualizar parsers do treesitter
