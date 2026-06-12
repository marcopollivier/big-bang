# WezTerm

Configuração do [WezTerm](https://wezfurlong.org/wezterm/), meu terminal.

O arquivo de config é o [`.wezterm.lua`](./.wezterm.lua) desta pasta.

## Instalação (máquina nova)

```bash
# Terminal
brew install --cask wezterm

# Fonte usada na config
brew install --cask font-hack-nerd-font
```

## Onde a config precisa ficar

O WezTerm procura a configuração, nesta ordem:

1. Variável de ambiente `$WEZTERM_CONFIG_FILE`
2. `~/.wezterm.lua`
3. `~/.config/wezterm/wezterm.lua`

A forma recomendada é o `just link` (na raiz do repo), que symlinka este arquivo
para `~/.config/wezterm/wezterm.lua`. Manualmente:

```bash
ln -sfn "$PWD/wezterm/.wezterm.lua" ~/.config/wezterm/wezterm.lua
```

> Depois de editar a config, é só salvar — o WezTerm recarrega automaticamente.
> Se houver erro de Lua, ele mostra um popup apontando a linha do problema.

## O que está configurado

### Fonte
| Opção | Valor | Por quê |
|---|---|---|
| `font` | Hack Nerd Font Mono | Fonte mono com ícones (Nerd Font) |
| `font_size` | 15.0 | Tamanho base |
| `adjust_window_size_when_changing_font_size` | `false` | A janela não fica pulando de tamanho ao mudar a fonte |

### Aparência
| Opção | Valor | Por quê |
|---|---|---|
| `color_scheme` | Catppuccin Mocha | Tema escuro |
| `window_background_opacity` | 0.95 | Leve transparência |
| `macos_window_background_blur` | 20 | Desfoca o fundo atrás da janela (combina com a transparência) |
| `window_decorations` | `TITLE \| RESIZE` | Mantém barra de título e permite redimensionar |
| `window_padding` | 8px | Folga entre o texto e as bordas |
| `default_cursor_style` | BlinkingBar | Cursor em barrinha piscando (estilo editor) |
| `inactive_pane_hsb` | escurece | Escurece o pane fora de foco, pra saber onde você está |

### Abas (tabs)
| Opção | Valor |
|---|---|
| `enable_tab_bar` | `true` |
| `hide_tab_bar_if_only_one_tab` | `false` |
| `use_fancy_tab_bar` | `false` (barra de abas simples/compacta) |

### Comportamento
| Opção | Valor | Por quê |
|---|---|---|
| `check_for_updates` | `false` | Não checa atualização (instalo via brew) |
| `scrollback_lines` | 10000 | Histórico de rolagem |
| `audible_bell` | `Disabled` | Sem "bip" sonoro |
| copy-on-select | mouse binding | Selecionar com o mouse já copia pro clipboard (estilo iTerm/tmux) |

## Atalhos

> No macOS, `CMD` é a tecla ⌘.

### Geral
| Atalho | Ação |
|---|---|
| `CMD + K` | Limpa o terminal (scrollback + viewport) |
| `CMD + Shift + P` | Paleta de comandos (busca qualquer ação do WezTerm) |

### Fonte
| Atalho | Ação |
|---|---|
| `CMD + =` / `CMD + +` | Aumenta a fonte |
| `CMD + -` | Diminui a fonte |
| `CMD + 0` | Reseta a fonte ao tamanho original |

### Panes (divisões da tela)
| Atalho | Ação |
|---|---|
| `CMD + Enter` | Split em cima/embaixo (`SplitVertical` — novo pane **abaixo**) |
| `CMD + Shift + Enter` | Split lado a lado (`SplitHorizontal` — novo pane **à direita**) |
| `CMD + W` | Fecha o pane atual |
| `CMD + setas` | Move o foco entre panes |
| `CMD + Ctrl + setas` | Redimensiona o pane atual |
| `CMD + Shift + Z` | Zoom: foca um pane em tela cheia e volta |

### Histórico / cópia
| Atalho | Ação |
|---|---|
| `CMD + Shift + X` | Modo de cópia: navega o histórico pelo teclado e copia sem mouse |

## Glossário

- **Pane (split):** dividir uma mesma aba em vários quadrados de terminal lado a lado.
- **Tab (aba):** como abas do navegador — cada uma é um terminal separado.
- **Scrollback:** o histórico de linhas que já saíram da tela e você pode rolar pra ver de novo.
- **Nerd Font:** fonte com ícones embutidos (usados por prompts como Starship, temas de editor, etc.).
