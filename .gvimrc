if has("win32")
    set guifont=Consolas:14
elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h16
else
    set guifont=Bitstream\ Vera\ Sans\ Mono\ 12
endif

colorscheme rdark

set number
set numberwidth=4
set columns=84

if has("colorcolumn")
    set cc=81
    highlight ColorColumn ctermbg=grey ctermfg=white guibg=#2c3032
endif

set list listchars=tab:>·,trail:·
