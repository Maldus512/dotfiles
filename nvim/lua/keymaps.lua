local escapeMap = require("utils").map
local vim = vim


-- Toggleterm
function _G.set_terminal_keymaps()
    --local opts = {buffer = 0}
    --vim.keymap.set('n', '<leader>h', [[<C-\><C-n>:ToggleTerm<CR>:ToggleTerm direction=horizontal size=20<CR>]], opts)
    --vim.keymap.set('n', '<leader>v', [[<C-\><C-n>:ToggleTerm<CR>:ToggleTerm direction=vertical size=80<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')


-- Movement
vim.keymap.set("n", "<Esc>", ":noh<CR><Esc>", { silent = true }) -- Hide search highlights by pressing Escape
vim.keymap.set({ 'n', 'i' }, '<C-o>', '<C-o>zz')
vim.keymap.set({ 'n', 'i' }, '<C-i>', '<C-i>zz')
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
escapeMap({ "n", "i" }, "<C-'>", "g;zz", { silent = true })
escapeMap({ "n", "i" }, "<C-;>", "g,zz", { silent = true })


-- Dropbar
do
    local dropbar = require("dropbar.api")
    local utils = require('dropbar.utils')
    local selectLast = function()
        local bar = utils.bar.get_current()
        if true or not bar then
            dropbar.pick()
        else
            local last = #(bar.components)
            dropbar.pick(last)
        end
    end
    vim.keymap.set({ "n" }, "<Leader>n", selectLast)
    escapeMap({ "n", "i" }, "<C-n>", selectLast)
end


-- Reader
vim.keymap.set({ 'n' }, '<Leader>l', ":ReadLine<CR>")
--vim.keymap.set({ 'n' }, '<Leader>n', ":ReadName<CR>")
vim.keymap.set({ 'n' }, '<Leader><Leader>', ":ReadCompletion<CR>")

--Debug
local dap = require("dap")
local dap_ui = require("dapui")
vim.keymap.set('n', '<F4>', function() dap.terminate() end)
vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
--vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() dap.set_breakpoint() end)
vim.keymap.set('n', '<Leader>D', function() dap_ui.toggle() end)

-- Spectre
vim.keymap.set('n', '<leader>f', '<cmd>lua require("spectre").open()<CR>', {
    desc = "Open Spectre"
})
vim.keymap.set('v', '<leader>f', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
})
vim.keymap.set("v", "r", "y:%s/\\V<C-r>0//gc<left><left><left>", { noremap = true })
vim.keymap.set("v", "/", "yq/p<CR>", { noremap = true })

-- NvimTree
escapeMap("n", "<Leader>e", ":NvimTreeFindFileToggle<CR>", { silent = true })

-- Smart splits
vim.keymap.set({ 'n', 'i', 't' }, '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set({ 'n', 'i', 't' }, '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set({ 'n', 'i', 't' }, '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set({ 'n', 'i', 't' }, '<C-l>', require('smart-splits').move_cursor_right)

-- Telescope
local telescope = require("telescope.builtin")
vim.keymap.set({ "n", "i" }, "<C-p>", function() telescope.find_files() end)
escapeMap({ "n" }, "<leader>P", ":Telescope commands<CR>")
escapeMap({ "n" }, "<leader><Enter>", ":Telescope commands<CR>")
vim.keymap.set({ "n" }, "<leader>p", function() telescope.find_files() end)
--escapeMap({ "n" }, "<leader>/", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<C-/>", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
vim.keymap.set("n", "<leader>/", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
escapeMap({ "n", "i" }, "<C-Enter>", ":Telescope commands<CR>")
escapeMap({ "n" }, "<leader><tab>", ":Telescope buffers<CR>")
escapeMap({ "n" }, "<leader>b", ":Telescope buffers<CR>")
escapeMap({ "n", "i" }, "<C-b>", ":Telescope buffers<CR>")
vim.api.nvim_create_user_command("SearchAllFiles", function()
    telescope.find_files({ no_ignore = true })
end, {})

local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
vim.keymap.set({ "s", "v" }, "<C-/>", live_grep_args_shortcuts.grep_visual_selection)
vim.keymap.set({ "s", "v" }, "<leader>/", live_grep_args_shortcuts.grep_visual_selection)


--[[
--Base shortcuts
--]]
escapeMap("n", "`<Esc>", "<C-\\><C-n>", { silent = true })

--escapeMap("n", "<Leader>q", ":enew<bar>bd #<CR>", { silent = true })
escapeMap("n", "<Leader>q", ":Bdelete this<CR>", { silent = true })
escapeMap("n", "<Leader>Q", ":Bdelete! this<CR>", { silent = true })
escapeMap("n", "<C-->", ":split<CR>")
escapeMap("n", "<C-\\>", ":vsplit<CR>")
escapeMap("n", "<leader>-", ":split<CR>")
escapeMap("n", "<leader>\\", ":vsplit<CR>")

-- Cycle through buffers; I don't care about flying
escapeMap({ "n", "i" }, "<C-.>", ":BufferNext<CR>", { silent = true })
escapeMap({ "n", "i" }, "<C-,>", ":BufferPrevious<CR>", { silent = true })
escapeMap({ "n" }, "<leader>.", ":BufferNext<CR>", { silent = true })
escapeMap({ "n" }, "<leader>,", ":BufferPrevious<CR>", { silent = true })
escapeMap({ "n", "i" }, "<C-Right>", ":BufferNext<CR>", { silent = true })
escapeMap({ "n", "i" }, "<C-Left>", ":BufferPrevious<CR>", { silent = true })
escapeMap({ "n", "i" }, "<C-Tab>", ":BufferNext<CR>", { silent = true })
escapeMap({ "n", "i" }, "<C-S-Tab>", ":BufferPrevious<CR>", { silent = true })
escapeMap({ "n" }, "<leader>z", ":edit #<CR>", { silent = true })
escapeMap({ "n", "i" }, "<c-z>", ":edit #<CR>", { silent = true })

escapeMap({ "n", "i" }, "<C-a>", ":OverseerToggle right<CR>", { silent = true })
escapeMap({ "n" }, "<leader>a", ":OverseerToggle right<CR>", { silent = true })


--[[
-- Coc
--]]
-- Autocomplete
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(0) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
    opts)
vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(0) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
vim.keymap.set("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
--vim.keymap.set("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })
vim.keymap.set("i", "<c-space>", function()
        local tocall = vim.fn["coc#refresh"]()
        local command = string.match(tocall, "=([ -~]+)")
        if command ~= nil then
            vim.cmd("call " .. command)
        end
    end,
    { silent = true, expr = true })
--
--


-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
vim.keymap.set("n", "g[", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.keymap.set("n", "g]", "<Plug>(coc-diagnostic-next)", { silent = true })

-- GoTo code navigation
vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set({ "n", "i" }, "<C-]>", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })


-- Use K to show documentation in preview window
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end

vim.keymap.set("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })

-- Symbol renaming
--vim.keymap.set("n", "<leader>cr", "<Plug>(coc-rename)", { silent = true })



-- Apply codeAction to the selected region
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
vim.keymap.set("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
vim.keymap.set("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

-- Remap keys for apply code actions at the cursor position.
vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply code actions affect whole buffer.
vim.keymap.set("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- Remap keys for applying codeActions to the current buffer
vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction)", opts)
-- Apply the most preferred quickfix action on the current line.
-- vim.keymap.set("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- Remap keys for apply refactor code actions.
--vim.keymap.set("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
--vim.keymap.set("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
--vim.keymap.set("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

-- Run the Code Lens actions on the current line
vim.keymap.set("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
vim.keymap.set("x", "if", "<Plug>(coc-funcobj-i)", opts)
vim.keymap.set("o", "if", "<Plug>(coc-funcobj-i)", opts)
vim.keymap.set("x", "af", "<Plug>(coc-funcobj-a)", opts)
vim.keymap.set("o", "af", "<Plug>(coc-funcobj-a)", opts)
vim.keymap.set("x", "ic", "<Plug>(coc-classobj-i)", opts)
vim.keymap.set("o", "ic", "<Plug>(coc-classobj-i)", opts)
vim.keymap.set("x", "ac", "<Plug>(coc-classobj-a)", opts)
vim.keymap.set("o", "ac", "<Plug>(coc-classobj-a)", opts)


-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
vim.keymap.set("n", "<C-y>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-y>"', opts)
vim.keymap.set("n", "<C-e>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-e>"', opts)
vim.keymap.set("i", "<C-y>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
vim.keymap.set("i", "<C-e>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
vim.keymap.set("v", "<C-y>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-y>"', opts)
vim.keymap.set("v", "<C-e>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-e>"', opts)


-- Use CTRL-S for selections ranges
-- Requires 'textDocument/selectionRange' support of language server
vim.keymap.set("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
vim.keymap.set("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
--local opts = { silent = true, nowait = true }
-- Show all diagnostics
--vim.keymap.set("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
-- Manage extensions
--vim.keymap.set("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands
--vim.keymap.set("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
-- Find symbol of current document
--vim.keymap.set("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
-- Search workspace symbols
--vim.keymap.set("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
-- Do default action for next item
--vim.keymap.set("n", "<space>j", ":<C-u>CocNext<cr>", opts)
-- Do default action for previous item
--vim.keymap.set("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list
--vim.keymap.set("n", "<space>p", ":<C-u>CocListResume<cr>", opts)

escapeMap({ "n", "i" }, "<C-f>", ":Format<CR>", { silent = true })
escapeMap({ "n", "i", "v" }, "<C-S-I>", ":Format<CR>", { silent = true })

-- Formatting selected code
vim.keymap.set("v", "<C-f>", "<Plug>(coc-format-selected)", { silent = true })
vim.keymap.set("v", "<C-S-i>", "<Plug>(coc-format-selected)", { silent = true })
