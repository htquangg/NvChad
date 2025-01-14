--type conform.options
local options = {
  lsp_fallback = true,

  formatters_by_ft = {
    lua = { "stylua" },

    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    tsx = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    html = { "prettier" },
    yaml = { "yamlfix" },
    vue = { "prettier" },

    go = { "goimports", "gofumpt" },

    sh = { "shfmt" },
    php = { "php-cs-fixer" },
    blade = { "blade-formatter" },
    proto = { "buf" },
    rust = { "rustfmt", lsp_format = "fallback" },
  },
  -- adding same formatter for multiple filetypes can look too much work for some
  -- instead of the above code you could just use a loop! the config is just a table after all!

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

require("conform").setup(options)
