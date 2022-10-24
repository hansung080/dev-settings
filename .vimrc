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

" Move the cursor to the cursor's position of the last open file.
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif

" Show the current cursor's position.
set laststatus=2
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F

" File Encoding for Korean
if $LANG[0] == 'k' && $LANG[1] == 'o'
  set fileencoding=korea
endif

" Syntax Highlighting for Go
filetype on
au BufRead,BufNewFile *.go set filetype=go