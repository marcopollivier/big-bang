-- Opções gerais do editor
local opt = vim.opt

opt.number = true            -- número da linha
opt.relativenumber = true    -- números relativos (navegação rápida com j/k)
opt.mouse = "a"              -- mouse habilitado
opt.showmode = false         -- a statusline já mostra o modo
opt.clipboard = "unnamedplus" -- usa o clipboard do sistema
opt.breakindent = true
opt.undofile = true          -- undo persistente entre sessões
opt.ignorecase = true        -- busca case-insensitive...
opt.smartcase = true         -- ...a não ser que tenha maiúscula
opt.signcolumn = "yes"       -- sempre mostra a coluna de sinais (evita "pulo")
opt.updatetime = 250         -- resposta mais rápida (diagnósticos, gitsigns)
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.inccommand = "split"     -- preview de :substitute
opt.cursorline = true
opt.scrolloff = 10
opt.termguicolors = true     -- cores 24-bit

-- Indentação (4 espaços como padrão; treesitter/ftplugins ajustam por linguagem)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

-- Lista de caracteres invisíveis
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Realça o texto copiado por um instante
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Realçar texto ao copiar (yank)",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
