# Custom vim installation, containing all plugins and the .vimrc
{ pkgs }:

with pkgs;
(vim_configurable.customize
  {
    name = "vim";
    vimrcConfig = {
      beforePlugins = ''
        set nocompatible
        set encoding=utf-8 "Required for YouCompleteMe to load properly
      '';
      plug.plugins = with pkgs.vimPlugins; [ vim-colors-solarized YouCompleteMe vim-airline vim-airline-themes vim-fugitive undotree ];
      customRC = ''
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

        set background=dark
        let g:airline_theme='solarized'
        silent! colorscheme solarized
        highlight SpecialKey ctermbg=none

        let g:airline#extensions#tabline#enabled = 1

        let mapleader = " "
      '';
    };
  })
