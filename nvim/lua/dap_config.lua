local vim = vim
local dap = require('dap')
local log = require("log")

-- Utility functions

local get_mason_installed_plugin = function(exe)
    return vim.fn.stdpath("data") .. "/mason/bin/" .. exe
end

dap.adapters.dart = {
    type = "executable",
    -- As of this writing, this functionality is open for review in https://github.com/flutter/flutter/pull/91802
    command = "flutter",
    args = { "debug_adapter" }
}

-- Adapters

dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = get_mason_installed_plugin("codelldb"),
        args = { "--port", "${port}" },
        -- On windows you may have to uncomment this:
        -- detached = false,
    }
}


dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
}

local dapui = require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
    vim.hydras.debug:activate()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    vim.hydras.debug:exit()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    vim.hydras.debug:exit()
    dapui.close()
end

-- Map K to hover during debug sessions
--[[
local api = vim.api
local keymap_restore = {}
dap.listeners.after['event_initialized']['me'] = function()
    for _, buf in pairs(api.nvim_list_bufs()) do
        local keymaps = api.nvim_buf_get_keymap(buf, 'n')
        for _, keymap in pairs(keymaps) do
            if keymap.lhs == "K" then
                table.insert(keymap_restore, keymap)
                api.nvim_buf_del_keymap(buf, 'n', 'K')
            end
        end
    end
    api.nvim_set_keymap(
        'n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
end

dap.listeners.after['event_terminated']['me'] = function()
    for _, keymap in pairs(keymap_restore) do
        api.nvim_buf_set_keymap(
            keymap.buffer,
            keymap.mode,
            keymap.lhs,
            keymap.rhs,
            { silent = keymap.silent == 1 }
        )
    end
    keymap_restore = {}
end
--]]
-- Default configurations
--

local function mk_env()
    local variables = {}
    for k, v in pairs(vim.fn.environ()) do
        variables[k] = v
    end
    return variables
end

dap.configurations.c = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        env = mk_env(),
    },
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c
dap.configurations.zig = dap.configurations.c

-- Custom configurations

local setup_c_configuration = function(file)
    return {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = file,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    }
end


vim.dap = {
    setup_c_configuration = setup_c_configuration,
    setup_rust_configuration = setup_c_configuration,
    setup_cpp_configuration = setup_c_configuration,
    setup_zig_configuration = setup_c_configuration,
}
