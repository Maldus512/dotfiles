local dropbar = require('dropbar')
local utils = require('dropbar.utils')

dropbar.setup {
    sources = {
        path = {
            filter = function(path)
                local endswith = function(string, suffix)
                    return string:sub(- #suffix) == suffix
                end

                return not endswith(path, ".o")
            end
        },
    },
    menu = {
        keymaps = {
            ['l'] = function()
                local menu = utils.menu.get_current()
                if not menu then
                    return
                end
                local cursor = vim.api.nvim_win_get_cursor(menu.win)
                local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
                if component then
                    menu:click_on(component, nil, 1, 'l')
                end
            end,
            ['L'] = function()
                local api = require("dropbar.api")
                local menu = api.get_current_dropbar_menu()
                if menu then
                    return api.goto_context_start(1)
                end
            end,
            ['H'] = function()
                local api = require("dropbar.api")
                local menu = api.get_current_dropbar_menu()
                if menu then
                    return api.goto_context_start(1)
                end
            end,
            ['h'] = "<C-w>q"
        },
    },
}
