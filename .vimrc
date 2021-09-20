syntax on

set encoding=utf-8
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set smartcase
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set modeline

set listchars=eol:↵,tab:>-,space:·,trail:⨯,extends:,precedes:

set colorcolumn=73,80,100
highlight ColorColumn ctermbg=0 guibg=lightgrey

let g:ycm_python_binary_path = '/usr/bin/python3.8'

call plug#begin('~/.vim/plugged')

Plug 'altercation/vim-colors-solarized'
"Plug 'ycm-core/YouCompleteMe'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'Yggdroot/indentLine'

call plug#end()

set background=dark
let g:airline_theme='solarized'
silent! colorscheme solarized

let g:airline#extensions#tabline#enabled = 1

let mapleader = " "

