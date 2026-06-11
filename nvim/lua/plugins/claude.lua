return {
  -- Biblioteca usada pelo claudecode pra janela do terminal (e utilidades em geral)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      -- Terminal embutido de uso geral
      { "<C-/>", function() Snacks.terminal() end, desc = "Terminal", mode = { "n", "t" } },
      { "<C-_>", function() Snacks.terminal() end, desc = "Terminal (compat)", mode = { "n", "t" } },
    },
  },

  -- Integração IDE com o Claude Code:
  -- o Claude enxerga sua seleção/arquivo atual e abre os diffs dentro do Neovim.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks",
      },
    },
    keys = {
      { "<leader>a", nil, desc = "IA / Claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Abrir/fechar Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focar no Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Retomar sessão" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continuar última sessão" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Adicionar buffer atual ao contexto" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Enviar seleção ao Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Adicionar arquivo da árvore ao contexto",
        ft = { "neo-tree", "neo-tree-popup" },
      },
      -- Aceitar / recusar diffs propostos pelo Claude
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Aceitar diff do Claude" },
      { "<leader>ax", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Recusar diff do Claude" },
    },
  },
}
