local vim = vim

vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

--vim.cmd [[highlight IndentBlanklineSpaceChar guifg=#606070 gui=nocombine]]
 

--require("ibl").setup {
--    space_char_blankline = " ",
    --show_current_context = true,
    --show_current_context_start = true,
--}
 
require("ibl").setup { }
