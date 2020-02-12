filetype plugin indent on
set backspace=indent,eol,start
syntax on
set encoding=utf-8
set number
set cursorline
set showmatch
set ruler
set noshowmode
set ttimeoutlen=10

set tabstop=2
set softtabstop=2
set expandtab

let mapleader = ","

highlight LineNr term=bold cterm=NONE ctermfg=DarkGray ctermbg=NONE gui=NONE guifg=DarkGray guibg=NONE

set termguicolors
set background=dark
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_italic=1
let g:gruvbox_italicize_strings=0
let g:gruvbox_filetype_hi_groups=1
let g:gruvbox_plugin_hi_groups=1
colorscheme gruvbox8_hard

let g:gitgutter_override_sign_column_highlight=0
autocmd ColorScheme gruvbox8_hard highlight SignColumn cterm=NONE guibg=DarkGray ctermbg=DarkGray

let NERDTreeDirArrows=1
let NERDTreeMinimalUI=1
let NERDTreeAutoDeleteBuffer=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

let g:airline_theme='gruvbox'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='unique_tail_improved'
let g:airline#extensions#tabline#buffer_min_count=2
let g:airline#extensions#whitespace#enabled=1

let asmsyntax="nasm"

" Show trailing whiitesace and tabs
function! ToggleWhitespace()
  if &list
    set nolist
    highlight clear ExtraWhitespace
    AirlineToggleWhitespace
  else
    AirlineToggleWhitespace
    if &listchars ==# 'eol:$'
      set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
    endif
    set list
    highlight ExtraWhitespace ctermbg=DarkGreen guibg=DarkGreen
    match ExtraWhitespace /\s\+$/
  endif
endfunction

map ; :Files<CR>
nmap <F2> :NERDTreeFocus<CR>
nmap <F3> :TagbarToggle<CR>
nnoremap <Leader>t :NERDTreeFocus<CR>
nnoremap <Leader>r :NERDTreeRefreshRoot<CR>
nnoremap <Leader>w :call ToggleWhitespace()<CR>

nnoremap <Leader><S-Tab> :bprevious<CR>
nnoremap <Leader><Tab> :bnext<CR>
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
