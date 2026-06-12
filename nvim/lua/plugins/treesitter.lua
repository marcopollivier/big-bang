return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- API clássica (configs.setup); a branch `main` é uma reescrita incompatível
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "go",
        "gomod",
        "gosum",
        "gowork",
        "c_sharp",
        "kotlin",
        "lua",
        "vim",
        "vimdoc",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
        "bash",
        "gitignore",
        "gitcommit",
        "dockerfile",
        "sql",
      },
      auto_install = true, -- instala parser ao abrir um filetype novo
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
