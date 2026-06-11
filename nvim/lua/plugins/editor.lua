return {
  -- Ícones (dependência de vários plugins)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Árvore de arquivos
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "Árvore de arquivos" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
      },
      window = { width = 32 },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
    },
  },

  -- Sinais de git na coluna lateral
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- Mostra os atalhos disponíveis enquanto você digita
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Buscar (find)" },
        { "<leader>a", group = "IA / Claude" },
        { "<leader>d", group = "Diagnóstico / Debug" },
        { "<leader>g", group = "Git / Go to" },
        { "<leader>c", group = "Código (code)" },
      },
    },
  },

  -- Fecha pares de aspas/parênteses automaticamente
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Comentar/descomentar com gcc / gc (visual)
  { "numToStr/Comment.nvim", opts = {} },

  -- Guias de indentação
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
}
