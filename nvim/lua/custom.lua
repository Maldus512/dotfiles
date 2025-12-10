local vim = vim;

vim.cmd("command CloseOthers Bdelete other")
vim.cmd("command CloseAll Bdelete all")
vim.cmd("command CloseThis Bdelete this")
vim.cmd("command ClearSearch noh")

vim.cmd("command Search lua require('spectre').open()")

vim.api.nvim_create_user_command("Debug", function()
    require('dap').continue()
end, {})
vim.api.nvim_create_user_command("DebugInterface", function()
    require('dapui').toggle()
end, {})

vim.api.nvim_create_user_command("ToggleTermHorizontal", "ToggleTerm direction=horizontal", {})
vim.api.nvim_create_user_command("ToggleTermVertical", "ToggleTerm direction=vertical", {})
vim.api.nvim_create_user_command("ToggleTermFloating", "ToggleTerm direction=float", {})

-- Copy current file path
vim.api.nvim_create_user_command("CopyAbsPath", "let @+ = expand('%:p')", {})
vim.api.nvim_create_user_command("CopyPath", "let @+ = expand('%')", {})

vim.api.nvim_create_user_command("CocRename", "call CocActionAsync('rename')<CR>", {})

--vim.opt.titlestring = [[%{expand("%")} %h%m%r%w - %{luaeval("require('utils').current_dir_basename()")} - %{v:progname}]]

local previous_window_bufid = 0

vim.api.nvim_create_autocmd({ "WinEnter", "VimEnter" }, {
    pattern = { "*" },
    callback = function()
        vim.opt.cursorline = true
        --local previous_window_buftype = vim.api.nvim_buf_get_option(previous_window_bufid, "buftype")
        --local previous_window_bufname = vim.api.nvim_buf_get_name(previous_window_bufid)
        --if previous_window_buftype == "terminal" and (string.find(previous_window_bufname, "lldb_wrap.sh") or string.find(previous_window_bufname, "gdb_wrap.sh")) then
        --vim.api.nvim_buf_set_option(previous_window_bufid, "cursorline", true)
        --else
        --vim.api.nvim_buf_set_option(previous_window_bufid, "cursorline", false)
        --end
    end
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
    pattern = { "*" },
    callback = function()
        local curid = vim.api.nvim_get_current_win()
        previous_window_bufid = vim.api.nvim_win_get_buf(curid)
        vim.opt.cursorline = false
    end
})

vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
    pattern = { "*" },
    callback = function()
        local utils = require("utils")

        local curid = vim.api.nvim_get_current_win()
        local curbufid = vim.api.nvim_win_get_buf(curid)
        local current_window_buftype = vim.api.nvim_buf_get_option(curbufid, "buftype")

        if current_window_buftype ~= "terminal" then
            local titlestring = utils.basename(vim.fn.expand('%')) .. " - " .. utils.current_dir_basename() .. " - Nvim"

            vim.opt.titlestring = titlestring
            vim.cmd([[set title]])

            if vim.fn.exists("$TMUX") then
                vim.fn.system("tmux rename-window '" .. titlestring .. "'")
            end
        end
    end
})

vim.api.nvim_create_autocmd({ "VimLeave" }, {
    pattern = { "*" },
    callback = function()
        if vim.fn.exists("$TMUX") then
            vim.fn.system("tmux setw automatic-rename")
        end
    end
})

vim.g.markdown_folding = 1

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldlevel = 99
  end,
})

--vim.cmd([[ autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif ]])

--[[
--vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*"},
  callback = function()
        local curid = vim.api.nvim_get_current_win()
        local curbufid = vim.api.nvim_win_get_buf(curid)
        local current_window_buftype = vim.api.nvim_buf_get_option(curbufid, "buftype")

        print("Ciao " .. current_window_buftype .. "<<")
        if (current_window_buftype == "terminal") then
            vim.cmd("startinsert")
        end
  end
})
]]
--[[vim.api.nvim_create_autocmd({"WinEnter"}, {
  pattern = {"*"},
  callback = function(ev)
    print(string.format('event fired: s', vim.inspect(ev)))
  end
})
]]
