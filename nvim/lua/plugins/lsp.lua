return {
  -- Mason: instalador de language servers, formatadores e debuggers
  { "williamboman/mason.nvim", opts = {} },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Language servers
        "gopls",                    -- Go
        "omnisharp",                -- C# / .NET
        "kotlin-language-server",   -- Kotlin
        "lua-language-server",      -- Lua (para editar esta própria config)
        -- Formatadores
        "gofumpt",
        "goimports",
        "csharpier",
        "ktlint",
        "stylua",
        -- Debug
        "delve",                    -- debugger do Go
        "netcoredbg",               -- debugger do .NET / C#
        "kotlin-debug-adapter",     -- debugger do Kotlin
      },
    },
  },

  -- Progresso do LSP no canto da tela
  { "j-hui/fidget.nvim", opts = {} },

  -- Configuração dos servidores (API nativa do Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "j-hui/fidget.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Capabilities turbinadas pelo nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Config padrão aplicada a TODOS os servidores
      vim.lsp.config("*", { capabilities = capabilities })

      -- Go
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            analyses = { unusedparams = true, nilness = true, unusedwrite = true },
            staticcheck = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -- C# / .NET (cmd vem do spec do lspconfig, com os flags --languageserver etc.;
      -- o binário do Mason é resolvido via PATH)
      vim.lsp.config("omnisharp", {
        settings = {
          FormattingOptions = { EnableEditorConfigSupport = true },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            enableDecompilationSupport = true,
          },
        },
      })

      -- Kotlin: usa o spec padrão (binário via PATH, exige raiz de projeto
      -- Gradle/Maven: build.gradle(.kts), settings.gradle(.kts), pom.xml)

      -- Lua (reconhece a API `vim` para não reclamar)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkthirdparty = false },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      -- Habilita os servidores
      vim.lsp.enable({ "gopls", "omnisharp", "kotlin_language_server", "lua_ls" })

      -- Aparência dos diagnósticos
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
          },
        },
      })

      -- Atalhos definidos só quando um LSP "anexa" ao buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local builtin = require("telescope.builtin")
          local function map(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", builtin.lsp_definitions, "Ir para definição")
          map("gr", builtin.lsp_references, "Referências")
          map("gI", builtin.lsp_implementations, "Implementações")
          map("<leader>D", builtin.lsp_type_definitions, "Definição de tipo")
          map("<leader>ds", builtin.lsp_document_symbols, "Símbolos do documento")
          map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "Símbolos do workspace")
          map("K", vim.lsp.buf.hover, "Documentação (hover)")
          map("gD", vim.lsp.buf.declaration, "Ir para declaração")
          map("<leader>rn", vim.lsp.buf.rename, "Renomear símbolo")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })

          -- Inlay hints (toggle)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Alternar inlay hints")
          end
        end,
      })
    end,
  },
}
