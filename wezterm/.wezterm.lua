local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- Fonte
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 15.0

-- Aparência
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.95
config.window_decorations = "TITLE | RESIZE"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

-- Comportamento
config.check_for_updates = false
config.scrollback_lines = 5000

-- Atalhos
config.keys = {
  -- Limpar terminal (como no iTerm)
  { key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

  -- Splits
  { key = "Enter", mods = "CMD", action = act.SplitVertical({}) },
  { key = "Enter", mods = "CMD|SHIFT", action = act.SplitHorizontal({}) },
  { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

  -- Navegação entre panes
  { key = "LeftArrow", mods = "CMD", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD", action = act.ActivatePaneDirection("Down") },

  -- Tamanho da fonte
  { key = "=", mods = "CMD", action = act.IncreaseFontSize },
  { key = "+", mods = "CMD", action = act.IncreaseFontSize },
  { key = "-", mods = "CMD", action = act.DecreaseFontSize },
  { key = "0", mods = "CMD", action = act.ResetFontSize },
}

return config
