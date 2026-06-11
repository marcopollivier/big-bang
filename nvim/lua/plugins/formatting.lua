return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Formatar arquivo/seleção",
      },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        cs = { "csharpier" },
        kotlin = { "ktlint" },
        lua = { "stylua" },
      },
      -- Formata ao salvar; cai pro LSP se não houver formatador específico
      format_on_save = function(bufnr)
        local disable_filetypes = {}
        local lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback"
        return { timeout_ms = 1500, lsp_format = lsp_format }
      end,
    },
  },
}
