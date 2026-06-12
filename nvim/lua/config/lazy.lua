-- Bootstrap do gerenciador de plugins lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Falha ao clonar o lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Carrega todos os specs de plugins de lua/plugins/
require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true, notify = false }, -- checa updates em background
  change_detection = { notify = false },
})
