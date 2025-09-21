return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "williamboman/mason.nvim",
    "j-hui/fidget.nvim",
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },

  config = function()
    require("lspconfig").lua_ls.setup {}

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
        "clangd",
        "gopls",
      },


      -- vim.api.nvim_create_autocmd('LspAttach', {
      --   group = vim.api.nvim_create_augroup('my.lsp', {}),
      --   callback = function(args)
      --     local client = vim.lsp.get_client_by_id(args.data.client_id)
      --     if not client then return end
      --
      --     if client:supports_method('textDocument/formatting') then
      --       vim.api.nvim_create_autocmd('BufWritePre', {
      --         group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
      --         buffer = args.buf,
      --         callback = function()
      --           vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
      --         end,
      --       })
      --     end
      --   end,
      -- })
      handlers = {
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim", "it", "describe", "before_each", "after_each" },
                }
              }
            }
          }
        end,

        ["gopls"] = function()
          local lspconfig = require("lspconfig")

          -- Create the augroup ONCE (no global clearing here)
          local fmt_group = vim.api.nvim_create_augroup("LspFormatOnSave", {})

          lspconfig.gopls.setup {
            capabilities = capabilities,
            settings = { gopls = { gofumpt = true } },

            on_attach = function(client, bufnr)
              -- Prefer the API check; some servers use dynamic capability registration
              if client.supports_method and client:supports_method("textDocument/formatting") then
                -- Clear any existing autocmd for THIS buffer only
                vim.api.nvim_clear_autocmds({ group = fmt_group, buffer = bufnr })

                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = fmt_group,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format({
                      bufnr = bufnr,
                      async = false,
                      timeout_ms = 3000,
                      -- ensure gopls is the one formatting
                      filter = function(cl) return cl.name == "gopls" end,
                    })
                  end,
                })
              end
            end,
          }
        end,

        ["ts_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.tsserver.setup {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format({ async = false })
                  end,
                })
              end
            end,
          }
        end,
      }
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end
}
