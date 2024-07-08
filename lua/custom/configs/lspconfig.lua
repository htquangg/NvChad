local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = {
  "html",
  "cssls",
  "volar",
  "tsserver",
  "gopls",
  "sqls",
  "bashls",
  "yamlls",
  "bufls",
  "jsonls",
  "tailwindcss",
  "terraformls",
  "tflint",
  "dockerls",
  "lua_ls",
}

for _, lsp in ipairs(servers) do
  if lsp == "yamlls" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      schemas = {
        ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
      },
    }
  elseif lsp == "volar" then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
    }
  elseif lsp == "tsserver" then
    lspconfig[lsp].setup {
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = "/Users/mac/.nvm/versions/node/v16.20.2/lib/node_modules/@vue/typescript-plugin",
            languages = { "javascript", "typescript", "vue" },
          },
        },
      },
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { "typescript", "javascript", "vue" },
    }
  else
    lspconfig[lsp].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end
end

--
-- lspconfig.pyright.setup { blabla}
