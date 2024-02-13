local vim = vim

vim.g.mapleader=" "
vim.o.timeoutlen = 500
vim.o.mouse = "a"
vim.o.number = true
vim.o.numberwidth = 1
vim.o.hidden = true
vim.o.wrap = false

vim.o.clipboard = vim.o.clipboard .. "unnamedplus"
--vim.api.nvim_set_option("clipboard","unnamed")
vim.api.nvim_set_option("showmatch", true)
vim.api.nvim_set_option("hlsearch", true)
vim.api.nvim_set_option("smartcase", true)
vim.api.nvim_set_option("incsearch", true)
vim.api.nvim_set_option("autoindent", true)
vim.api.nvim_set_option("cindent", true)
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.api.nvim_set_option("smartindent", true)
vim.o.smarttab = true
vim.o.softtabstop = 4
--vim.api.nvim_set_option("termguicolors", true)
--
vim.o.ruler = true
vim.o.backup = true
vim.o.undolevels = 100
vim.o.backspace = "indent,eol,start"
vim.o.encoding = "utf-8"
vim.o.splitbelow = true
