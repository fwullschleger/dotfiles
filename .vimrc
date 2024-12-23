let mapleader=" "

" relative numbering
set relativenumber

" leave insert mode,
inoremap jj <ESC>

" Ctrl-D or Ctrl-U will perform the usual scroll operation
" followed by centering the cursor line in the middle of the screen
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" maps Alt-A/X to perform an increment
nnoremap <A-a> <C-a>
nnoremap <A-x> <C-x>
