local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ===========================================================================
-- Fonte
-- ===========================================================================
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 15.0
-- Não redimensiona a janela ao aumentar/diminuir a fonte (mantém o layout estável).
config.adjust_window_size_when_changing_font_size = false

-- ===========================================================================
-- Aparência
-- ===========================================================================
config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.95
-- Desfoca o que está atrás da janela transparente (fica bem melhor no macOS).
config.macos_window_background_blur = 20
config.window_decorations = "TITLE | RESIZE"
-- Uma respiração entre o texto e as bordas da janela.
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

-- Cursor: barra piscando (estilo editor). Alternativas: "SteadyBlock", "BlinkingBlock".
config.default_cursor_style = "BlinkingBar"

-- Escurece levemente os panes que não estão em foco, pra saber onde você está.
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.7,
}

-- ===========================================================================
-- Abas (tabs)
-- ===========================================================================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
-- Mostra o número da aba no título (1., 2., ...) — facilita pular com CMD+número.
config.tab_and_split_indices_are_zero_based = false

-- ===========================================================================
-- Comportamento
-- ===========================================================================
config.check_for_updates = false
-- Mais histórico de rolagem pra trás (era 5000).
config.scrollback_lines = 10000
-- Sem "bip" sonoro irritante.
config.audible_bell = "Disabled"
-- Seleciona texto com o mouse já copia pro clipboard (estilo iTerm/tmux).
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("ClipboardAndPrimarySelection"),
  },
}

-- ===========================================================================
-- Atalhos
-- ===========================================================================
config.keys = {
  -- Limpar terminal (como no iTerm)
  { key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

  -- Splits:  CMD+Enter = pane novo EMBAIXO (em cima/baixo) · CMD+Shift+Enter = pane novo À DIREITA (lado a lado)
  { key = "Enter", mods = "CMD", action = act.SplitVertical({}) },
  { key = "Enter", mods = "CMD|SHIFT", action = act.SplitHorizontal({}) },
  { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

  -- Navegação entre panes (mover o foco)
  { key = "LeftArrow", mods = "CMD", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD", action = act.ActivatePaneDirection("Down") },

  -- Redimensionar panes (CMD+CTRL+seta)
  { key = "LeftArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "UpArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "DownArrow", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },

  -- Foca um pane em tela cheia e volta (zoom). Ótimo pra ler logs sem distração.
  { key = "z", mods = "CMD|SHIFT", action = act.TogglePaneZoomState },

  -- Modo de cópia/scrollback pelo teclado (setas/hjkl pra navegar, depois copiar).
  { key = "x", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

  -- Paleta de comandos: digita pra achar qualquer ação do WezTerm.
  { key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },

  -- Tamanho da fonte
  { key = "=", mods = "CMD", action = act.IncreaseFontSize },
  { key = "+", mods = "CMD", action = act.IncreaseFontSize },
  { key = "-", mods = "CMD", action = act.DecreaseFontSize },
  { key = "0", mods = "CMD", action = act.ResetFontSize },
}

-- ===========================================================================
-- Status bars: máquina (esquerda) · consumo do Claude Code (direita)
-- ===========================================================================
-- Esquerda  → wezterm/sysinfo.sh: "CPU 6% · MEM 7%" (recursos da máquina).
-- Direita   → claude/usage.sh: "$61/$300 · 20% · hoje $9 · proj $295" (gasto do
--             mês vs limite + hoje + projeção; estimativa local via ccusage, bate
--             com a UI do Claude; limite em ~/.claude/usage-budget).
-- Ambos os scripts têm cache próprio, então cada tick aqui é barato.
local repo = wezterm.home_dir .. "/dev/marcopollivier/big-bang"
local usage_script = repo .. "/claude/usage.sh"
local sysinfo_script = repo .. "/wezterm/sysinfo.sh"

-- Cor por nível de uso (verde → amarelo → laranja → vermelho).
local function level_color(pct, yellow, orange, red)
  if pct then
    if pct >= red then
      return "#f7768e"
    elseif pct >= orange then
      return "#ff9e64"
    elseif pct >= yellow then
      return "#e0af68"
    end
  end
  return "#9ece6a"
end

wezterm.on("update-status", function(window, _pane)
  -- Direita: consumo do Claude Code. Cor pela % do limite (60/70/85).
  local ok, usage = wezterm.run_child_process({ usage_script })
  usage = (ok and usage or ""):gsub("%s+$", "")
  if usage == "" or usage == "…" then
    window:set_right_status("")
  else
    local pct = tonumber(usage:match("(%d+)%%"))
    window:set_right_status(wezterm.format({
      { Foreground = { Color = level_color(pct, 60, 70, 85) } },
      { Text = "󰚩 " .. usage .. "  " },
    }))
  end

  -- Esquerda: recursos da máquina. Cor pelo maior entre CPU/MEM (70/85/95).
  local ok2, sys = wezterm.run_child_process({ sysinfo_script })
  sys = (ok2 and sys or ""):gsub("%s+$", "")
  if sys == "" or sys == "…" then
    window:set_left_status("")
  else
    local hi = 0
    for n in sys:gmatch("(%d+)%%") do
      local v = tonumber(n)
      if v and v > hi then
        hi = v
      end
    end
    window:set_left_status(wezterm.format({
      { Foreground = { Color = level_color(hi, 70, 85, 95) } },
      { Text = "  " .. sys .. " " },
    }))
  end
end)

-- A cada quantos ms o WezTerm reavalia os status (os scripts têm cache próprio).
config.status_update_interval = 10000

return config
