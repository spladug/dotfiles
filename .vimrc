" load pathogen
filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

" tell pydiction where to look
let g:pydiction_location = '~/.vim/bundle/pydiction/complete-dict'

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

" space around the current line
set scrolloff=4

" use metacharacters in regular expressions by default
nnoremap / /\v
vnoremap / /\v

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
map <leader>n :NERDTreeToggle<CR>

" hide generated files from NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$', '\.png$', '\.gif$', '\.o$', '\.so$']
set wildignore+=*.pyc,*~,*.png,*.gif,*.so,*.o,*.html.py,*.compact.py,*.mobile.py,*.htmllite.py

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
let g:ackprg="ack -H --nocolor --nogroup --column"
map <leader>a :Ack 

" highlight columns
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" trailing whitespace is bad
hi ExtraWhitespace guifg=#eeeeec guibg=#880000
autocmd BufWinEnter * match ExtraWhitespace /\s\+\%#\@<!$/

" keep visual selection after indenting
vmap > >gv
vmap < <gv

" but don't expand tabs for makefiles
augroup neils_commands
    au!

    au BufEnter * let &titlestring=expand("%:p")." - VIM"
    au BufEnter [Mm]akefile* set noexpandtab

    au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

    au BufRead *.pig set syntax=pig
augroup END
