local wezterm = require 'wezterm'
local act = wezterm.action

return {
  -- Fonte
  font = wezterm.font("Hack Nerd Font Mono"),
  font_size = 15.0,

  -- Aparência
  color_scheme = "Catppuccin Mocha",
  window_background_opacity = 0.95,
  window_decorations = "TITLE | RESIZE",
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = false,

  -- Comportamento
  check_for_updates = false,
  scrollback_lines = 5000,

  -- Atalhos
  keys = {
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

    -- Aumentar fonte
    { key = "=", mods = "CMD", action = act.IncreaseFontSize },
    { key = "+", mods = "CMD", action = act.IncreaseFontSize },

  },
}
