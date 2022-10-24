" .vimrc

" Syntax Highlighting
if has("syntax")
    syn on
endif

" Basic Settings
set nu
set autoindent
set cindent
set ts=4
set shiftwidth=4
set paste

" Search Settings
set hls
set incsearch
set wrap
set smartcase

" Put cursor position at the last open cursor position.
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif

" Show current cursor position.
set laststatus=2
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F

" Korean File Encoding
if $LANG[0] == 'k' && $LANG[1] == 'o'
    set fileencoding=korea
endif

" Syntax Highlighting for GO
filetype on
au BufRead,BufNewFile *.go set filetype=go
