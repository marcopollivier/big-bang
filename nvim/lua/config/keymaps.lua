-- Atalhos gerais (atalhos de plugins ficam nos arquivos dos plugins;
-- atalhos de LSP ficam no autocmd LspAttach em plugins/lsp.lua)
local map = vim.keymap.set

-- Limpar destaque de busca com <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Salvar / sair
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Salvar arquivo" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Fechar janela" })

-- Navegação entre janelas (splits) com Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w><C-h>", { desc = "Janela à esquerda" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Janela à direita" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Janela abaixo" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Janela acima" })

-- Mover linhas selecionadas (visual) com J/K
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover seleção para baixo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover seleção para cima" })

-- Manter cursor centralizado ao rolar / buscar
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Diagnósticos rápidos
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Diagnóstico anterior" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Próximo diagnóstico" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Mostrar diagnóstico da linha" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Lista de diagnósticos" })

-- Sair do modo terminal com <Esc><Esc>
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Sair do modo terminal" })
