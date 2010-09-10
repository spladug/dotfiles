" turn off vi compatibility
set nocompatible

" line numbers
set ruler

" show commands while typing
set showcmd

" tabulation
set expandtab
set smarttab
set tabstop=4
set shiftwidth=4

" indentation
set autoindent
set smartindent

" space around the current line
set scrolloff=4

" case insensitive matching unless otherwise specified
set ignorecase
set smartcase

" search while typing
set hlsearch
set incsearch

" file completion
set wildmenu
set wildmode=list:longest

" configure gvim
set guioptions-=T
set guioptions-=m
set guitablabel=%-0.12t%m

" scroll a bit faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" highlight lines that are too long
highlight OverLength ctermbg=red ctermfg=white guibg=red guifg=white
match OverLength '\%81v.*'

" highlight redundant whitespace and tabs
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t|\t/

" gvim tabs
map tl :tabnext<CR>
map th :tabprev<CR>
map <C-t> :tabnew<CR>

let mapleader = ","
map <leader>t :NERDTreeToggle<CR>
map <leader>o goq

" hide generated files from NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$', '^ui_', '^moc_', '\.png$', '\.gif$']

" fix backspace
set backspace=indent,eol,start

" don't ding me, bro
set visualbell

" syntax highlighting on and colorfy
syntax enable
filetype on
filetype plugin on
filetype indent on

" keep visual selection after indenting
vmap > >gv
vmap < <gv

" but don't expand tabs for makefiles
augroup neils_commands
    au!

    au BufEnter * let &titlestring=expand("%:p")." - VIM"
    au BufEnter [Mm]akefile* set noexpandtab

    au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
augroup END
