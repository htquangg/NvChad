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
      settings = {
        yaml = {
          disableDefaultProperties = true,
          schemaStore = {
            url = "https://www.schemastore.org/api/json/catalog.json",
            enable = true,
          },
          schemas = {
            ["file:///home/arccy/third_party/kubernetes-json-schema/default/v1.27.3-standalone/all.json"] = {
              "*.k8s.yaml",
            },
            kubernetes = "",
          },
          yamlEditor = {
            ["editor.insertSpaces"] = false,
            ["editor.formatOnType"] = false,
          },
        },
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
      filetypes = {
        "typescript",
        "javascript",
        "vue",
        "javascriptreact",
        "typescriptreact",
        "typescript.tsx",
        "javascript.jsx",
      },
    }
  elseif lsp == "gopls" then
    lspconfig[lsp].setup {
      -- cmd = { 'gopls', '-logfile=/tmp/gopls.log' }, -- save file and :PackerCompile to take effect
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          gofumpt = true,
          staticcheck = true,
          templateExtensions = { "gotmpl" },
          vulncheck = "Imports",
          analyses = {
            shadow = true,
          },
        },
      },
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if path:find "sdk/go" then
          client.config.settings.gopls.gofumpt = false
        end
      end,
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
