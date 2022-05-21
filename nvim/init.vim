syntax on
set mouse=a
set number
set numberwidth=1
set hidden

let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 3
let g:netrw_winsize=25


"" General
set showmatch	" Highlight matching brace
set hlsearch	" Highlight all search results
set smartcase	" Enable smart-case search
set incsearch	" Searches for strings incrementally
set autoindent	" Auto-indent new lines
set cindent	" Use 'C' style program indenting
set expandtab	" Use spaces instead of tabs
set shiftwidth=4	" Number of auto-indent spaces
set smartindent	" Enable smart-indent
set smarttab	" Enable smart-tabs
set softtabstop=4	" Number of spaces per Tab
 
"" Advanced{ 'do': './install --all && ln -sf $(pwd) ~/.fzf'}
set ruler	" Show row and column ruler information
 
set backup
set backupdir=~/.cache/vimbackup/	" Backup directories
 
set undolevels=100	" Number of undo levels
set backspace=indent,eol,start	" Backspace behaviour

set encoding=utf-8
set splitbelow

"" Colors
colorscheme apprentice
highlight OverLength ctermbg=gray ctermfg=black guibg=#FFD9D9
match OverLength /\%121v.\+/
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"" Minpac
packadd minpac
call minpac#init()
" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
call minpac#add('k-takata/minpac', {'type': 'opt'})
call minpac#add('junegunn/fzf')
call minpac#add('junegunn/fzf.vim')
call minpac#add('vim-airline/vim-airline')
call minpac#add('Asheq/close-buffers.vim')
call minpac#add('preservim/nerdtree')
call minpac#add('romainl/Apprentice')
call minpac#add('rhysd/vim-clang-format')
call minpac#add('tpope/vim-fugitive')
""call minpac#add('neoclide/coc.nvim', {'do': './install.sh'})
""call minpac#add('ycm-core/YouCompleteMe')

"" Custom shortcuts
" open files with fzf and open buffers
nnoremap <C-p> :<C-u>FZF<Cr>
nnoremap <C-b> :ls<cr>:b<space>

nmap <C-w>e :NERDTreeToggle<cr>
nmap <C-w>i :ClangFormat<cr>
nmap <C-w>w :Bdelete this<cr>

" Cycle through buffers; I don't care about flying
nmap <C-w>n :bn<cr>
nmap <C-w>p :bp<cr>

"" YouCompleteMe
let g:ycm_confirm_extra_conf = 0

"" Fuzzy search actions
let g:fzf_action = {
  \ 'enter': 'e',
  \ 'ctrl-t': 'tab drop',
  \ 'ctrl-h': 'split',
  \ 'ctrl-v': 'vsplit' }

"" Airline
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

"" NERDTree
let g:NERDTreeWinSize=20
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


"" Coc configuration
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif
