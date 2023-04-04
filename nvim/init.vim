"" Lua
lua require("packer_config")
lua require("config")

lua require("config_local_config")
lua require("apprentice_config")
lua require("coc_config")
lua require("gitsign_config")
lua require("telescope_config")
lua require("blankline_config")
lua require("toggleterm_config")
lua require("treesitter_config")
lua require("nvimtree_config")
""lua require("winsep_config")
lua require("smartsplits_config")
lua require("lualine_config")
lua require("barbar_config")
lua require("tint_config")
lua require("virtcolumn_config")
lua require("custom")

lua require("hydras")
lua require("keymaps")
""lua require("tmux_config")
""lua require("barbar_config")


"" Colors
""set colorcolumn=80
""highlight VirtColumn ctermbg=gray guifg=#383030
hi Visual  guibg=#484848 
  ""dark4 = hsl("#bcbcbc"),
""highlight OverLength ctermbg=black ctermfg=black guibg=#201010
""match OverLength /\%121v.\+/
""highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"" Config
set backupdir=~/.cache/nvimbackup/

""set statusline+=%{get(b:,'gitsigns_status','')}

""autocmd BufWinEnter,WinEnter * if &buftype == 'terminal' | silent! normal i | endif
""autocmd TermOpen * startinsert
""autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufEnter * if &buftype == 'terminal' | :startinsert | endif

" Background colors for active vs inactive windows
" hi ActiveWindow guibg=#181818
"hi InactiveWindow guibg=#303030
hi InactiveWindow guibg=#000000

" Call method on window enter
"augroup WindowManagement
"  autocmd!
"  autocmd WinEnter * call Handle_Win_Enter()
"  autocmd WinNew * call Handle_Win_Enter()
"augroup END

" Change highlight group of active/inactive windows
function! Handle_Win_Enter()
  ""setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
  setlocal winhighlight=NormalNC:InactiveWindow
endfunction
