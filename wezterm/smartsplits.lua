local w = require('wezterm')

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function is_vim(pane)
    local process_name = basename(pane:get_foreground_process_name())
    return process_name == 'nvim' or process_name == 'vim'
end

local direction_keys = {
    Left = 'h',
    Down = 'j',
    Up = 'k',
    Right = 'l',
    -- reverse lookup
    h = 'Left',
    j = 'Down',
    k = 'Up',
    l = 'Right',
}

local function split_nav(resize_or_move, key)
    return {
        key = key,
        mods = resize_or_move == 'resize' and 'CTRL|SHIFT' or 'CTRL',
        action = w.action_callback(function(win, pane)
            if is_vim(pane) then
                -- pass the keys through to vim/nvim
                win:perform_action({
                    SendKey = { key = key, mods = resize_or_move == 'resize' and 'CTRL|SHIFT' or 'CTRL' },
                }, pane)
            else
                if resize_or_move == 'resize' then
                    win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
                else
                    win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
                end
            end
        end),
    }
end

act = w.action

return {
    keys = {
        -- move between split panes
        split_nav('move', 'h'),
        split_nav('move', 'j'),
        split_nav('move', 'k'),
        split_nav('move', 'l'),
        -- resize panes
        split_nav('resize', 'h'),
        split_nav('resize', 'j'),
        split_nav('resize', 'k'),
        split_nav('resize', 'l'),
        {
            mods = 'LEADER',
            key = 'r',
            action = act.ActivateKeyTable {
                name = 'resize_pane',
                one_shot = false,
            },
        }
    },
    key_tables = {
        -- Defines the keys that are active in our resize-pane mode.
        -- Since we're likely to want to make multiple adjustments,
        -- we made the activation one_shot=false. We therefore need
        -- to define a key assignment for getting out of this mode.
        -- 'resize_pane' here corresponds to the name="resize_pane" in
        -- the key assignments above.
        resize_pane = {
            { key = 'H',          action = act.AdjustPaneSize { 'Left', 1 } },
            { key = 'h',          action = act.ActivatePaneDirection('Left') },
            { key = 'L',          action = act.AdjustPaneSize { 'Right', 1 } },
            { key = 'l',          action = act.ActivatePaneDirection('Right') },
            { key = 'K',          action = act.AdjustPaneSize { 'Up', 1 } },
            { key = 'k',          action = act.ActivatePaneDirection('Up') },
            { key = 'J',          action = act.AdjustPaneSize { 'Down', 1 } },
            { key = 'j',          action = act.ActivatePaneDirection('Down') },
            -- Cancel the mode by pressing escape
            { key = 'Escape',     action = 'PopKeyTable' },
        },
    }
}
