local map = require("utils").map
local keyset = vim.keymap.set

--[[
--NvimTree
--]]
map("n", "<Leader>e", ":NvimTreeToggle<CR>", { silent = true })

--[[
--Smart splits
--]]
vim.keymap.set({ 'n', 'i', 't' }, '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set({ 'n', 'i', 't' }, '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set({ 'n', 'i', 't' }, '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set({ 'n', 'i', 't' }, '<C-l>', require('smart-splits').move_cursor_right)
vim.keymap.set({ 'n', 'i', 't' }, '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set({ 'n', 'i', 't' }, '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set({ 'n', 'i', 't' }, '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set({ 'n', 'i', 't' }, '<C-l>', require('smart-splits').move_cursor_right)

--[[
--Telescope
--]]
map({ "n", "i" }, "<C-p>", ":Telescope find_files<CR>")
map({ "n", "i" }, "<C-/>", ":Telescope live_grep<CR>")
map({ "n", "i" }, "<C-S-p>", ":Telescope commands<CR>")
map({ "n", "i" }, "<C-Tab>", ":Telescope buffers<CR>")
vim.api.nvim_create_user_command("SearchAllFiles", function ()
   require("telescope.builtin").find_files({no_ignore=true})
end, {})


--[[
--Toggleterm
--]]
map({ "n", "i" }, "<C-t>", ":ToggleTerm direction=float<CR>", { silent = true })
map("t", "<C-t>", "<C-\\><C-n>:ToggleTerm direction=float<CR>", { silent = true })
map("t", "<Esc>", "<C-\\><C-n>", { silent = true })
map({ "n", "i" }, "<C-x>", ":ToggleTerm size=16<CR>", { silent = true })
map("t", "<C-x>", "<C-\\><C-n>:ToggleTerm <CR>", { silent = true })

--[[
--Base shortcuts
--]]
map("t", "`<Esc>", "<C-\\><C-n>", { silent = true })

map("n", "<Leader>q", ":Bdelete this<CR>", { silent = true })
map("n", "<Leader>Q", ":Bdelete! this<CR>", { silent = true })
map("n", "<Leader>-", ":split<CR>")
map("n", "<Leader>\\", ":vsplit<CR>")

-- Cycle through buffers; I don't care about flying
map({ "n", "i" }, "<C-.>", ":BufferNext<CR>", { silent = true })
map({ "n", "i" }, "<C-,>", ":BufferPrevious<CR>", { silent = true })
map({ "n", "i" }, "<C-b>", ":BufferLast<CR>", { silent = true })


--[[
--Coc
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
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "g[", "<Plug>(coc-diagnostic-prev)", { silent = true })
keyset("n", "g]", "<Plug>(coc-diagnostic-next)", { silent = true })

-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
keyset({ "n", "i" }, "<C-]>", "<Plug>(coc-definition)", { silent = true })
keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
keyset("n", "gr", "<Plug>(coc-references)", { silent = true })


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

keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })

-- Symbol renaming
keyset("n", "<leader>cr", "<Plug>(coc-rename)", { silent = true })



-- Apply codeAction to the selected region
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

-- Remap keys for apply code actions at the cursor position.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply code actions affect whole buffer.
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- Remap keys for applying codeActions to the current buffer
keyset("n", "<leader>ac", "<Plug>(coc-codeaction)", opts)
-- Apply the most preferred quickfix action on the current line.
-- keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- Remap keys for apply refactor code actions.
--keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
--keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
--keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

-- Run the Code Lens actions on the current line
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)


-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset("i", "<C-f>",
    'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-b>",
    'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


-- Use CTRL-S for selections ranges
-- Requires 'textDocument/selectionRange' support of language server
keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
--local opts = { silent = true, nowait = true }
-- Show all diagnostics
--keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
-- Manage extensions
--keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands
--keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
-- Find symbol of current document
--keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
-- Search workspace symbols
--keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
-- Do default action for next item
--keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
-- Do default action for previous item
--keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list
--keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)

vim.keymap.del({ "n", "i", "v" }, "<C-F>")
map({ "n", "i" }, "<C-f>", ":Format<CR>", { silent = true })
map({ "n", "i", "v" }, "<C-S-I>", ":Format<CR>", { silent = true })

-- Formatting selected code
keyset("v", "<C-f>", "<Plug>(coc-format-selected)", { silent = true })
keyset("v", "<C-S-i>", "<Plug>(coc-format-selected)", { silent = true })
