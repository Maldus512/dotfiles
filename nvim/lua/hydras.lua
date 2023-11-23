local Hydra = require("hydra")
local gitsigns = require('gitsigns')

local hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_:                     _q_: exit
]]

Hydra({
    name = 'Git',
    hint = hint,
    config = {
        buffer = bufnr,
        color = 'red',
        invoke_on_body = true,
        hint = {
            border = 'rounded'
        },
        on_key = function() vim.wait(50) end,
        on_enter = function()
            vim.cmd 'mkview'
            vim.cmd 'silent! %foldopen!'
            gitsigns.toggle_signs(true)
            gitsigns.toggle_linehl(true)
        end,
        on_exit = function()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            vim.cmd 'loadview'
            vim.api.nvim_win_set_cursor(0, cursor_pos)
            vim.cmd 'normal zv'
            --gitsigns.toggle_signs(false)
            gitsigns.toggle_linehl(false)
            --gitsigns.toggle_deleted(false)
        end,
    },
    mode = { 'n', 'x' },
    body = '<leader>g',
    heads = {
        { 'J',
            function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gitsigns.next_hunk() end)
                return '<Ignore>'
            end,
            { expr = true, desc = 'next hunk' } },
        { 'K',
            function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gitsigns.prev_hunk() end)
                return '<Ignore>'
            end,
            { expr = true, desc = 'prev hunk' } },
        { 's',
            function()
                local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
                if mode == 'V' then                        -- visual-line mode
                    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
                    vim.api.nvim_feedkeys(esc, 'x', false) -- exit visual mode
                    vim.cmd("'<,'>Gitsigns stage_hunk")
                else
                    vim.cmd("Gitsigns stage_hunk")
                end
            end,
            { desc = 'stage hunk' } },
        { 'u',       gitsigns.undo_stage_hunk,                           { desc = 'undo last stage' } },
        { 'S',       gitsigns.stage_buffer,                              { desc = 'stage buffer' } },
        { 'p',       gitsigns.preview_hunk,                              { desc = 'preview hunk' } },
        { 'd',       gitsigns.toggle_deleted,                            { nowait = true, desc = 'toggle deleted' } },
        { 'b',       gitsigns.blame_line,                                { desc = 'blame' } },
        { 'B',       function() gitsigns.blame_line { full = true } end, { desc = 'blame show full' } },
        { '/',       gitsigns.show,                                      { exit = true, desc = 'show base file' } }, -- show the base of the file
        { '<Enter>', function() vim.cmd('Neogit') end,                   { exit = true, desc = 'Neogit' } },
        { 'q',       nil,                                                { exit = true, nowait = true, desc = 'exit' } },
    }
})

local splits = require('smart-splits')

local cmd = require('hydra.keymap-util').cmd
local pcmd = require('hydra.keymap-util').pcmd

local buffer_hint = [[
 ^^^^^^^^^^^^     Move         ^^     Misc
 ^^^^^^^^^^^^-------------     ^^---------------
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^      _p_: pin
 _h_ ^ ^ _l_  _H_ ^ ^ _L_      _t_ : To new tab
 _,_ ^ ^ _._  _<_ ^ ^ _>_      _w_: close
 focus^^^^^^  move ^^^^^^^     _ol_: order by lang
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^      _od_: order by dir
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^      ^
]]

local buffer_hydra = Hydra({
    name = 'Barbar',
    hint = buffer_hint,
    config = {
        invoke_on_body = true,
        on_key = function()
            -- Preserve animation
            vim.wait(200, function() vim.cmd 'redraw' end, 30, false)
        end
    },
    body = "<leader>t",
    heads = {
        { 'h',     function() vim.cmd('BufferPrevious') end,         { on_key = false } },
        { 'l',     function() vim.cmd('BufferNext') end,             { desc = 'choose', on_key = false } },
        { ',',     function() vim.cmd('BufferPrevious') end,         { on_key = false } },
        { '.',     function() vim.cmd('BufferNext') end,             { desc = 'choose', on_key = false } },
        { 'H',     function() vim.cmd('BufferMovePrevious') end },
        { 'L',     function() vim.cmd('BufferMoveNext') end,         { desc = 'move' } },
        { '<',     function() vim.cmd('BufferMovePrevious') end },
        { '>',     function() vim.cmd('BufferMoveNext') end,         { desc = 'move' } },
        { 'p',     function() vim.cmd('BufferPin') end,              { desc = 'pin' } },
        { 't',     '<C-W>T',                                         { desc = 'To new tab' } },
        { 'w',     function() vim.cmd('BufferClose') end,            { desc = 'close' } },
        { 'od',    function() vim.cmd('BufferOrderByDirectory') end, { desc = 'by directory' } },
        { 'ol',    function() vim.cmd('BufferOrderByLanguage') end,  { desc = 'by language' } },
        { '<Esc>', nil,                                              { exit = true } }
    }
})

local function choose_buffer()
    if #vim.fn.getbufinfo({ buflisted = true }) > 1 then
        buffer_hydra:activate()
    end
end

vim.keymap.set('n', 'gb', choose_buffer)

local window_hint = [[
 ^^^^^^^^^^^^     Move          ^^    Size   ^^   ^^     Split
 ^^^^^^^^^^^^----------------   ^^-----------^^   ^^---------------
 ^ ^ _k_ ^ ^  ^ ^  _<C-k>_ ^ ^      _K_ ^ ^       _s_: horizontally
 _h_ ^ ^ _l_  _<C-h>_ _<C-l>_   _H_ ^ ^ _L_       _v_: vertically
 ^ ^ _j_ ^ ^  ^ ^  _<C-j>_ ^ ^      _J_ ^ ^       _q_, _c_: close
 focus^^^^^^  window^^^^^^      ^_=_: equalize^   _z_: maximize
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^       ^^ ^          ^   _o_: remain only
 _b_: choose buffer
]]

Hydra({
    name = 'Windows',
    hint = window_hint,
    config = {
        invoke_on_body = true,
        hint = {
            border = 'rounded',
            offset = -1
        }
    },
    mode = 'n',
    body = '<leader>w',
    heads = {
        { 'h',     '<C-w>h' },
        { 'j',     '<C-w>j' },
        { 'k',     pcmd('wincmd k', 'E11', 'close') },
        { 'l',     '<C-w>l' },

        { '<C-h>', cmd 'WinShift left' },
        { '<C-j>', cmd 'WinShift down' },
        { '<C-k>', cmd 'WinShift up' },
        { '<C-l>', cmd 'WinShift right' },

        { 'H',     function() splits.resize_left(2) end },
        { 'J',     function() splits.resize_down(2) end },
        { 'K',     function() splits.resize_up(2) end },
        { 'L',     function() splits.resize_right(2) end },
        { '=',     '<C-w>=',                             { desc = 'equalize' } },

        { 's',     pcmd('split', 'E36') },
        { '<C-s>', pcmd('split', 'E36'),                 { desc = false } },
        { 'v',     pcmd('vsplit', 'E36') },
        { '<C-v>', pcmd('vsplit', 'E36'),                { desc = false } },
        { 'w',     '<C-w>w',                             { exit = true, desc = false } },
        { '<C-w>', '<C-w>w',                             { exit = true, desc = false } },
        { 'z',     cmd 'WindowsMaximaze',                { exit = true, desc = 'maximize' } },
        { '<C-z>', cmd 'WindowsMaximaze',                { exit = true, desc = false } },
        { 'o',     '<C-w>o',                             { exit = true, desc = 'remain only' } },
        { '<C-o>', '<C-w>o',                             { exit = true, desc = false } },
        { 'b',     choose_buffer,                        { exit = true, desc = 'choose buffer' } },
        { 'c',     pcmd('close', 'E444') },
        { 'q',     pcmd('close', 'E444'),                { desc = 'close window' } },
        { '<C-c>', pcmd('close', 'E444'),                { desc = false } },
        { '<C-q>', pcmd('close', 'E444'),                { desc = false } },
        { '<Esc>', nil,                                  { exit = true, desc = false } }
    }
})


local dap = require('dap')
local debug_hint = [[
 _q_: Close
 _x_: Terminate
 _r_: Open REPL
 _c_: Continue
 _n_: Step over
 _s_: Step into
 _o_: Step out
 _t_: Toggle breakpoint
 _T_: Clear breakpoints
]]
local debug_hydra = Hydra {
    name = 'Debug',
    hint = debug_hint,
    config = {
        color = 'pink',
        invoke_on_body = true,
        offset = 2,
        hint = {
            type = 'window',
            position = "top-right",
        },
    },
    mode = { 'n' },
    body = '<leader>d',
    heads = {
        { 'o', dap.step_out,          { desc = 'step out' } },
        { 'n', dap.step_over,         { desc = 'step over' } },
        --{ 'K', dap.step_back, { desc = 'step back' } },
        { 's', dap.step_into,         { desc = 'step into' } },
        { 't', dap.toggle_breakpoint, { desc = 'toggle breakpoint' } },
        { 'T', dap.clear_breakpoints, { desc = 'clear breakpoints' } },
        { 'c', dap.continue,          { desc = 'continue' } },
        { 'x', dap.terminate,         { desc = 'terminate', exit = true } },
        { 'r', dap.repl.toggle,         { desc = 'open repl' } },
        { 'q', nil,                   { exit = true, nowait = true, desc = 'exit' } },
    }
}

vim.hydras = { debug = debug_hydra }
