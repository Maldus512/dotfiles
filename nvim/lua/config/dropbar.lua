local dropbar = require('dropbar')
local utils = require('dropbar.utils')
local vim = vim

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
            ["H"] = function()
                local root = require("dropbar.utils").menu.get_current():root()
                root:close()

                local dropbar = require("dropbar.api").get_dropbar(vim.api.nvim_win_get_buf(root.prev_win), root
                    .prev_win)
                if not dropbar then
                    root:toggle()
                    return
                end

                local current_idx
                for idx, component in ipairs(dropbar.components) do
                    if component.menu == root then
                        current_idx = idx
                        break
                    end
                end

                if current_idx == nil or current_idx == 0 then
                    root:toggle()
                    return
                end

                vim.defer_fn(function() dropbar:pick(current_idx - 1) end, 100)
            end,

            ["L"] = function()
                local root = require("dropbar.utils").menu.get_current():root()
                root:close()

                local dropbar = require("dropbar.api").get_dropbar(vim.api.nvim_win_get_buf(root.prev_win), root
                    .prev_win)
                if not dropbar then
                    dropbar = require("dropbar.utils").bar.get_current()
                    if not dropbar then
                        root:toggle()
                        return
                    end
                end

                local current_idx
                for idx, component in ipairs(dropbar.components) do
                    if component.menu == root then
                        current_idx = idx
                        break
                    end
                end

                if current_idx == nil or current_idx == #dropbar.components then
                    root:toggle()
                    return
                end

                vim.defer_fn(function() dropbar:pick(current_idx + 1) end, 100)
            end,
            ['h'] = function()
                local api = require("dropbar.api")
                local menus = utils.menu.get()
                local bars = utils.bar.get()
                local bar = bars[1]

                local count = 0

                for _, _ in pairs(menus) do
                    count = count + 1
                end

                local result = tostring(#bar)
                for key, value in pairs(bar) do
                    count = count + 1
                    result = result .. " >" .. tostring(key) .. " >>" .. tostring(value)
                end
                print(result)

                if (count == 0) then
                    return
                    --elseif (count == 1 and bar and bar.currently_selected and bar.currently_selected > 1) then
                    --bar.currently_selected = bar.currently_selected - 1
                    --dropbar.pick(bar.currently_selected)
                else
                    vim.cmd.normal(vim.api.nvim_replace_termcodes("<C-w>q", true, true, true))
                end
                --"<C-w>q",
            end,
            ['i'] = function() end,
            ['/'] = function()
                local menu = utils.menu.get_current()
                if not menu then
                    return
                end
                menu:fuzzy_find_open()
            end,
        },
    },
}
