return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go", -- debug de Go pronto pra usar (usa o delve)
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug: continuar/iniciar" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>dt", function() require("dapui").toggle() end, desc = "Debug: alternar UI" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: REPL" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup()
      require("dap-go").setup() -- Go: configura o adapter (delve) automaticamente

      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

      -- ===== C# / .NET (netcoredbg) =====
      dap.adapters.coreclr = {
        type = "executable",
        command = mason_bin .. "netcoredbg",
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch (netcoredbg)",
          request = "launch",
          program = function()
            return vim.fn.input("Caminho da DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- ===== Kotlin (kotlin-debug-adapter) =====
      dap.adapters.kotlin = {
        type = "executable",
        command = mason_bin .. "kotlin-debug-adapter",
      }
      dap.configurations.kotlin = {
        {
          type = "kotlin",
          name = "Launch (kotlin)",
          request = "launch",
          projectRoot = "${workspaceFolder}",
          mainClass = function()
            return vim.fn.input("mainClass (ex.: MainKt): ")
          end,
        },
      }

      -- Abre/fecha a UI automaticamente
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },
}
