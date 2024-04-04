local M = {}

-- require("nvim-treesitter.install").prefer_git = true 
M.treesitter = {
  ensure_installed = {
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "cmake",
    "markdown",
    "markdown_inline",
    "go",
    "dockerfile",
    "gitcommit",
    "gitignore",
    "git_rebase",
    "gomod",
    "gowork",
    "jq",
    "json",
    "json5",
    "jsonc",
    "sql",
    "yaml",
    "rust",
    "python",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",
    "eslint_d",

    -- Go
    "gopls",
    "golangci-lint",
    "delve",
    "gofumpt",
    "goimports",
    "golines",
    "gotests",
    "gomodifytags",
    "iferr",
    "json-to-struct",
    "revive",

    -- SQL
    "sqls",
    "sqlfluff",
    "sql-formatter",

    -- File Formats
    "json-lsp",
    "jsonlint",
    "jq",
    "yaml-language-server",
    "yamllint",
    "yamlfmt",

    -- Git
    "commitlint",
    "gitlint",

    -- Shell
    "bash-language-server",
    -- "beautysh",
    "shfmt",
    -- "shellcheck",
    -- "shellharden",

    -- Others
    "ansible-language-server",
    "codespell",
    "dockerfile-language-server",
    "editorconfig-checker",
    -- "html-lsp",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
