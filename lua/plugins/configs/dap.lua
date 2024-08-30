local function string_starts(String, Start)
  return string.sub(String, 1, string.len(Start)) == Start
end

local function get_home()
  return os.getenv "HOME"
end

local function get_arguments()
  local co = coroutine.running()
  if co then
    return coroutine.create(function()
      local args = {}
      vim.ui.input({ prompt = "Args: " }, function(input)
        args = vim.split(input or "", " ")
      end)
      coroutine.resume(co, args)
    end)
  else
    local args = {}
    vim.ui.input({ prompt = "Args: " }, function(input)
      args = vim.split(input or "", " ")
    end)
    return args
  end
end

-- We are pulling this function out of nvim.dap because
-- we want to customize the behavior of the process picker

--- Return running processes as a list with { pid, name } tables.
local function get_processes()
  local is_windows = vim.fn.has "win32" == 1
  local separator = is_windows and "," or " \\+"
  local command = is_windows and { "tasklist", "/nh", "/fo", "csv" } or { "ps", "ah" }

  -- output format for `tasklist /nh /fo` csv
  --    '"smss.exe","600","Services","0","1,036 K"'
  -- output format for `ps ah`
  --    " 107021 pts/4    Ss     0:00 /bin/zsh <args>"
  local get_pid = function(parts)
    if is_windows then
      return vim.fn.trim(parts[2], '"')
    else
      return parts[1]
    end
  end

  local get_process_name = function(parts)
    if is_windows then
      return vim.fn.trim(parts[1], '"')
    else
      return table.concat({ unpack(parts, 5) }, " ")
    end
  end

  local output = vim.fn.system(command)
  local lines = vim.split(output, "\n")
  local procs = {}

  local unwanted_processes = {
    "-zsh",
    "/opt/homebrew/bin/nvim",
    get_home() .. "/.cache/gitstatus/gitstatusd-darwin-arm64",
    "tmux",
  }

  local nvim_pid = vim.fn.getpid()
  for _, line in pairs(lines) do
    if line ~= "" then -- tasklist command outputs additional empty line in the end
      local parts = vim.fn.split(vim.fn.trim(line), separator)
      local pid, name = get_pid(parts), get_process_name(parts)
      pid = tonumber(pid)
      if pid and pid ~= nvim_pid then
        local wanted = true
        for _, unwanted in ipairs(unwanted_processes) do
          if string_starts(name, unwanted) then
            wanted = false
            break
          end
        end
        if wanted then
          table.insert(procs, { pid = pid, name = name })
        end
      end
    end
  end

  return procs
end

--- Show a prompt to select a process pid
local function pick_process()
  local label_fn = function(proc)
    return string.format("id=%d name=%s", proc.pid, proc.name)
  end
  local co = coroutine.running()
  if co then
    return coroutine.create(function()
      local procs = get_processes()
      require("dap.ui").pick_one(procs, "Select process", label_fn, function(choice)
        coroutine.resume(co, choice and choice.pid or nil)
      end)
    end)
  else
    local procs = get_processes()
    local result = require("dap.ui").pick_one_sync(procs, "Select process", label_fn)
    return result and result.pid or nil
  end
end

local M = {}

M.config = function()
  local dap = require "dap"
  local dapui = require "dapui"

  require("dapui").setup()

  require("nvim-dap-virtual-text").setup {
    -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
    display_callback = function(variable)
      local name = string.lower(variable.name)
      local value = string.lower(variable.value)
      if name:match "secret" or name:match "api" or value:match "secret" or value:match "api" then
        return "*****"
      end

      if #variable.value > 15 then
        return " " .. string.sub(variable.value, 1, 15) .. "... "
      end

      return " " .. variable.value
    end,
  }

  vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "", linehl = "", numhl = "" })
  vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnosticError", linehl = "", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "", linehl = "", numhl = "" })
  vim.fn.sign_define(
    "DapStopped",
    { text = "󰁕 ", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" }
  )
  vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "", linehl = "", numhl = "" })

  -- dap.set_log_level("TRACE")

  -- Automatically open UI
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  -- Keybindings
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap("n", "<F4>", "<CMD>lua require('dap').step_back()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<F5>", "<CMD>lua require('dap').continue()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<S-F5>", "<CMD>lua require('dap').terminate()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<F9>", "<CMD>lua require('dap').toggle_breakpoint()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<F10>", "<CMD>lua require('dap').step_over()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<F11>", "<CMD>lua require('dap').step_into()<CR>", opts)
  vim.api.nvim_set_keymap("n", "<F12>", "<CMD>lua require('dap').step_out()<CR>", opts)
  vim.keymap.set("n", "<leader>di", function()
    require("dap.ui.widgets").hover()
  end)
  vim.keymap.set("n", "<leader>d?", function()
    local widgets = require "dap.ui.widgets"
    widgets.centered_float(widgets.scopes)
  end)
  vim.keymap.set("n", "<leader>dr", ':lua require"dap".repl.toggle({}, "vsplit")<CR><C-w>l')
  vim.keymap.set("n", "<leader>du", ':lua require"dapui".toggle()<CR>')
  vim.keymap.set("n", "<leader>dC", function()
    require("dap").clear_breakpoints()
  end)
  vim.keymap.set("n", "<leader>dn", function()
    require("dap").run_to_cursor()
  end)
  vim.keymap.set("n", "<leader>de", function()
    require("dap").set_exception_breakpoints { "all" }
  end)

  -- nvim-telescope/telescope-dap.nvim
  -- require("telescope").load_extension "dap"
  vim.keymap.set("n", "<leader>df", ":Telescope dap frames<CR>")
  -- vim.keymap.set('n', '<leader>dc', ':Telescope dap commands<CR>')
  vim.keymap.set("n", "<leader>db", function()
    require("dap").toggle_breakpoint()
  end)
  vim.keymap.set("n", "<leader>dB", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
  vim.keymap.set("n", "<leader>dl", ":Telescope dap list_breakpoints<CR>")

  dap.adapters.firefox = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/firefox-debug-adapter/dist/adapter.bundle.js" },
  }

  dap.adapters.node2 = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
  }

  dap.adapters.chrome = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
  }

  -- TODO: not working
  -- dap.adapters["pwa-node"] = {
  -- 	type = "server",
  -- 	host = "127.0.0.1",
  -- 	port = "9229",
  -- 	executable = {
  -- 		command = "js-debug-adapter",
  -- 		args = { "9229" },
  -- 	},
  -- }

  dap.configurations.typescript = {
    -- Working configs 🎉
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = "Node - Attach to process",
      type = "node2",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
    {
      name = "Firefox - Launch localhost",
      type = "firefox",
      request = "launch",
      reAttach = true,
      sourceMaps = true,
      url = "http://localhost:3000",
      -- TODO - webRoot should be set directly to workspaceFolder
      webRoot = "${workspaceFolder}/src",
      firefoxExecutable = "/usr/bin/firefox",
    },
    {
      name = "Chrome - Launch localhost",
      type = "chrome",
      request = "launch",
      runtimeExecutable = "/usr/bin/chromium",
      -- TODO - webRoot should be set directly to workspaceFolder
      webRoot = "${workspaceFolder}/src/build",
      url = "http://localhost:3000",
    },

    -- Not tested configs yet 🙀
    {
      name = "Nope - Node launch file",
      type = "node2",
      request = "launch",
      runtimeExecutable = "npm",
      runtimeArgs = { "run", "dev" },
      args = { "${file}" },
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      name = "Nope - Debug with Chrome",
      type = "chrome",
      request = "attach",
      sourceMaps = true,
      program = "${file}",
      port = 9222,
      webRoot = "${workspaceFolder}/src",
    },
    {
      name = "Nope - Run npm run dev",
      command = "npm run dev",
      request = "launch",
      type = "node-terminal",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Nope - Node - Launch with pwa-node",
      program = "${file}",
      cwd = "${workspaceFolder}",
      port = 9229,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Nope - Node - Attach with pwa-node",
      processId = require("dap.utils").pick_process,
      -- cwd = "${workspaceFolder}/src",
      -- port = 9229,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Nope - Node - Debug Jest Tests with pwa-node",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
  }

  dap.configurations.typescriptreact = dap.configurations.typescript
  dap.configurations.javascript = dap.configurations.typescript
  dap.configurations.javascriptreact = dap.configurations.typescript

  dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = {
      command = vim.fn.stdpath "data" .. "/mason/bin/dlv",
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  }

  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.configurations.go = {
    {
      type = "delve",
      name = "Debug",
      request = "launch",
      program = "${file}",
    },
    {
      type = "delve",
      name = "Debug (Arguments)",
      request = "launch",
      program = "${file}",
      args = get_arguments,
    },
    {
      type = "delve",
      name = "Debug test (main)", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}",
    },
    -- works with go.mod packages and sub packages
    {
      type = "delve",
      name = "Debug test (package)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
    },
    -- Build the binary (go build -gcflags=all="-N -l") and run it + pick it
    {
      type = "delve",
      name = "Attach To PID",
      mode = "local",
      request = "attach",
      processId = pick_process,
    },
    {
      type = "delve",
      name = "Attach To Port (:9080)",
      mode = "remote",
      request = "attach",
      port = "9080",
    },
  }

  local path = require("mason-registry").get_package("debugpy"):get_install_path()
end

return M
