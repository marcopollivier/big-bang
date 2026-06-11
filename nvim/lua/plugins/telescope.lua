return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
      })
      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      map("n", "<leader>ff", builtin.find_files, { desc = "Buscar arquivos" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Grep no projeto" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Buffers abertos" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Ajuda (help)" })
      map("n", "<leader>fr", builtin.oldfiles, { desc = "Arquivos recentes" })
      map("n", "<leader>fw", builtin.grep_string, { desc = "Buscar palavra sob o cursor" })
      map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnósticos do projeto" })
      map("n", "<leader><leader>", builtin.find_files, { desc = "Buscar arquivos" })
    end,
  },
}
