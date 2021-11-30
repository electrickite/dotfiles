" Do not use compatibility mode and UTF-8
set nocp
set encoding=utf-8

" Enable filetype detection and syntax highlighting
filetype plugin indent on
syntax on
let asmsyntax="nasm"

" Editor behavior
set backspace=indent,eol,start
set number
set cursorline
set showmatch
set ruler
set noshowmode
set ttimeoutlen=10
set spelllang=en_us

" Color and mouse support
set termguicolors
let &t_8f = "\<Esc>[38:2::%lu:%lu:%lum"
let &t_8b = "\<Esc>[48:2::%lu:%lu:%lum"
set ttymouse=sgr
set mouse=a


" Visual word wrapping defaults
set wrap
set linebreak
set textwidth=0
set wrapmargin=0

" Default tab behavior
set tabstop=2
set softtabstop=2
set expandtab

" Auto completion settings
set completeopt-=preview
set completeopt+=menuone,noinsert,noselect
set shortmess+=c
set belloff+=ctrlg
set tags+=~/.vim/systags
let g:mucomplete#enable_auto_at_startup=0
let g:mucomplete#chains = {
    \ 'default' : ['path', 'omni', 'keyn', 'dict', 'uspl'],
    \ 'vim'     : ['path', 'cmd', 'keyn'],
    \ 'c'       : ['path', 'user', 'omni', 'keyn', 'dict', 'uspl'],
    \ 'cpp'     : ['path', 'user', 'omni', 'keyn', 'dict', 'uspl']
    \ }

if has("autocmd") && exists("+omnifunc")
  autocmd Filetype *
          \	if &omnifunc == "" |
          \		setlocal omnifunc=syntaxcomplete#Complete |
          \	endif
endif
au FileType c setl completefunc=syntaxcomplete#Complete
au FileType cpp setl completefunc=syntaxcomplete#Complete

" Line highlighting
highlight LineNr term=bold cterm=NONE ctermfg=DarkGray ctermbg=NONE gui=NONE guifg=DarkGray guibg=NONE

" Color scheme
set termguicolors
set background=dark
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_italic=1
let g:gruvbox_italicize_strings=0
let g:gruvbox_filetype_hi_groups=1
let g:gruvbox_plugin_hi_groups=1
colorscheme gruvbox8_hard
autocmd ColorScheme gruvbox8_hard highlight SignColumn cterm=NONE guibg=DarkGray ctermbg=DarkGray

" Git gutter
let g:gitgutter_override_sign_column_highlight=0

" NERDTree settings
let NERDTreeDirArrows=1
let NERDTreeMinimalUI=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Airline settings
let g:airline_theme='gruvbox'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='unique_tail_improved'
let g:airline#extensions#tabline#buffer_min_count=2
let g:airline#extensions#whitespace#enabled=1

" Jump to last known valid cursor position when editing a file
augroup vimStartup
  au!
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END

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

" Set various word processor behaviors
func! WordProcessor()
  " movement changes
  map <buffer> j gj
  map <buffer> <Down> gj
  map <buffer> k gk
  map <buffer> <Up> gk
  " formatting text
  setlocal formatoptions=1
  setlocal noexpandtab
  setlocal wrap
  setlocal linebreak
  setlocal nolist
  " spell check
  setlocal spell
  " Disable code editing features
  setlocal noshowmatch
  setlocal noruler
  setlocal nocursorline
  setlocal nonumber
endfu

" Set Leader key to ,
let mapleader = ","

" :Qb command will close current buffer
command Qb bp | sp | bn | bd

" :WP command set word processor options
command! WP call WordProcessor()

" :sc80 and :sc120 shortcuts to set column width
command! Sc80 set columns=80
command! Sc120 set columns=120

" Key mappings and shortcuts
packadd vim-shortcut
Shortcut show shortcut menu and run chosen shortcut
  \ noremap <silent> <Leader><Leader> :Shortcuts<Return>
Shortcut fallback to shortcut menu on partial entry
  \ noremap <silent> <Leader> :Shortcuts<Return>

Shortcut search for files
  \ map ; :Files<CR>
Shortcut switch to file tree
  \ nmap <F2> :NERDTreeFocus<CR>
Shortcut open current file in file tree
  \ nmap <C-F2> :NERDTreeFind<CR>
Shortcut open tag panel
  \ nmap <F3> :TagbarOpenAutoClose<CR>
Shortcut generate tag file for current directory
  \ nmap <F12> :!ctags --totals -R .<CR>
Shortcut switch to file tree
  \ nnoremap <Leader>t :NERDTreeFocus<CR>
Shortcut refresh file tree
  \ nnoremap <Leader>r :NERDTreeRefreshRoot<CR>
Shortcut show/hide whitespace
  \ nnoremap <Leader>w :call ToggleWhitespace()<CR>
Shortcut search within files
  \ nnoremap <Leader>; :Ag<CR>

" Airline buffer 'tab' navigation
Shortcut next buffer nnoremap <Leader><Tab> :bnext<CR>
Shortcut previous buffer nnoremap <Leader><S-Tab> :bprevious<CR>
Shortcut switch to buffer 1 nmap <leader>1 <Plug>AirlineSelectTab1
Shortcut switch to buffer 2 nmap <leader>2 <Plug>AirlineSelectTab2
Shortcut switch to buffer 3 nmap <leader>3 <Plug>AirlineSelectTab3
Shortcut switch to buffer 4 nmap <leader>4 <Plug>AirlineSelectTab4
Shortcut switch to buffer 5 nmap <leader>5 <Plug>AirlineSelectTab5
