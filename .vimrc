" load pathogen
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" toggle between relative and absolute line numbers with C-l
function! g:ToggleNuMode()
    if(&rnu == 1)
        set nu
    else
        set rnu
    endif
endfunc

nnoremap <C-L> :call g:ToggleNuMode()<cr>

" don't wrap text
set nowrap

" make tabs and trailing whitespace visible
set list listchars=tab:>·,trail:·

" continue to show the piece of text you're in the process of changing
set cpoptions=$

" disable modelines for security
set modelines=0

" use utf8
set encoding=utf-8

" show commands while typing
set showcmd

" tabulation
set expandtab
set smarttab
set softtabstop=4
set tabstop=4
set shiftwidth=4

" indentation
set autoindent
set smartindent

" python tweaks 
au FileType python set complete+=k~/.vim/syntax/python.vim 
let python_slow_sync=1
au FileType python set colorcolumn=80
highlight ColorColumn ctermbg=darkgrey ctermfg=white

" space around the current line
set scrolloff=4

" global replacement by default
set gdefault

" case insensitive matching unless otherwise specified
set ignorecase
set smartcase

" search while typing
set hlsearch
set incsearch

" allow me to turn off highlighting after done with the search
map <leader><space> :noh<cr>

" file completion
set wildmenu
set wildmode=list:longest

" make tilde (case swap) an operator for maximum awesome
set tildeop

" configure gvim
set guioptions-=T
set guioptions-=m

" scroll a bit faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" gvim tabs
map tl :tabnext<CR>
map th :tabprev<CR>
map <C-t> :tabnew<CR>

let mapleader = ","

" make split navigation a bit cleaner
map <leader>" :split<CR>
map <leader>% :vsplit<CR>
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

" hide generated files
set wildignore+=*.pyc,*~,*.png,*.gif,*.so,*.o,*.html.py,*.compact.py,*.mobile.py,*.htmllite.py,*/build/*,*/.git/*

" fix backspace
set backspace=indent,eol,start

" don't ding me, bro
set visualbell

" syntax highlighting on and colorfy
syntax enable
filetype on
filetype plugin on
filetype indent on

" use ack for searching within projects
let g:ackprg="ack -H --nocolor --nogroup --column --ignore-dir=build"
map <leader>a :Ack 

" trailing whitespace is bad
hi ExtraWhitespace guifg=#eeeeec guibg=#880000
autocmd BufWinEnter * match ExtraWhitespace /\s\+\%#\@<!$/

" keep visual selection after indenting
vmap > >gv
vmap < <gv

" configure ctrl-p
let g:ctrlp_map = '<leader>t'
let g:ctrlp_working_path_mode = 0

" the default spelling colors are terrible for terminal (red on red)
highlight clear SpellBad
highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline

" but don't expand tabs for makefiles
augroup neils_commands
    au!

    au BufEnter * let &titlestring=expand("%:p")." - VIM"
    au BufEnter [Mm]akefile* set noexpandtab

    au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

    au BufRead *.pig set syntax=pig
augroup END

" configuration for syntastic
let g:syntastic_check_on_open=1  " don't wait 'til saving the file to check syntax
let g:syntastic_enable_signs=0  " get rid of the sign that screws up the left side
