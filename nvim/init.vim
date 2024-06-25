"
" see https://github.com/simrat39/dotfiles/tree/master/nvim/.config/nvim for
" inspiration
"" Lua
""lua require("packer_config")
lua require("config.lazy")
lua require("config.mason")
lua require("coc_config")
lua require("config.heirline.config")
lua require("config.overseer")
lua require("config.reader")
lua require("config")

lua require("config.neodev")
lua require("config_local_config")
lua require("colorscheme_config")
lua require("gitsign_config")
lua require("telescope_config")
lua require("toggleterm_config")
lua require("treesitter_config")
lua require("blankline_config")
lua require("nvimtree_config")
lua require("smartsplits_config")
""lua require("lualine_config")
lua require("barbar_config")
""lua require("virtcolumn_config")
lua require("dap_config")
lua require("config.dap_ui")
lua require("custom")

lua require("hydras")
lua require("keymaps")


let g:nvimgdb_config_override = {
  \ 'key_frameup': '<c-{>',
  \ 'key_framedown': '<c-}>',
  \ }

"" Config
set backupdir=~/.cache/nvimbackup/

" Background colors for active vs inactive windows
"hi ActiveWindow guibg=#181818
hi InactiveWindow guibg=#202020
"hi InactiveWindow guibg=#000000

" Call method on window enter
"augroup WindowManagement
  "autocmd!
  "autocmd WinEnter * call Handle_Win_Enter()
  "autocmd WinNew * call Handle_Win_Enter()
"augroup END

" Change highlight group of active/inactive windows
function! Handle_Win_Enter()
  "setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
  setlocal winhighlight=NormalNC:InactiveWindow
endfunction

"" Unicoder
let g:unicoder_command_abbreviations = 0
let g:unicoder_exclude_filetypes = ['tex', 'latex', 'plaintex', 'zig']
