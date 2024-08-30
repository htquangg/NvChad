---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },

    -- Git graph
    ["<leader>gl"] = {
      "<CMD>Flog<CR>",
      "Git graph",
    },
    ["<leader>gY"] = {
      function()
        require("gitlinker").get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})
      end
    },

    -- HOP around the screen with ease
    ["s"] = { "<CMD>HopChar2MW<CR>", "Hop anywhere" },
    ["f"] = { "<CMD>HopChar1AC<CR>", "Hop char 1 ac" },
    ["F"] = { "<CMD>HopChar1BC<CR>", "Hop char 1 bc" },
  },
  v = {
    [">"] = { ">gv", "indent" },

    -- HOP around the screen with ease
    ["s"] = { "<cmd>HopChar2MW<cr>", "Hop anywhere" },

    ["<leader>gY"] = {
      function()
        require("gitlinker").get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})
      end
    },
  },
}

-- more keybinds!

return M
