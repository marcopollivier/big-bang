return {
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- carrega no início
    priority = 1000, -- antes dos demais plugins
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
