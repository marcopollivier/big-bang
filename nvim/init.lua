-- ~/.config/nvim/init.lua
-- Ponto de entrada. O leader precisa ser definido ANTES do lazy carregar.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")
