# Custom vim installation, containing all plugins and the .vimrc
{ pkgs }:

with pkgs;
(vim-full.customize {
  name = "vim";
  vimrcConfig = {
    beforePlugins = ''
      set nocompatible
      set encoding=utf-8 "Required for YouCompleteMe to load properly
    '';
    packages.myPlugins = with pkgs.vimPlugins; {
      start = [
        vim-colors-solarized # Simple solarized theme, works well OOTB
        YouCompleteMe # Autocomplete
        vim-airline # Better status line
        vim-airline-themes # Themes for that status line
        vim-fugitive # Git integration
        undotree # Richer undo history
        surround-nvim # Surround content with braces, replace surrounding braces
        repeat # Makes built-in repeat command work with other scripts (for example surround)
      ];
      opt = [ ];
    };
    customRC = ''
      " Import default settings, especially syntax highlighting
      source ${vim-full}/share/vim/vim*/defaults.vim

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

      set backspace=indent,eol,start

      set colorcolumn=73,80,100
      highlight ColorColumn ctermbg=0 guibg=lightgrey

      set background=dark
      let g:airline_theme='solarized'
      silent! colorscheme solarized
      highlight SpecialKey ctermbg=none

      let g:airline#extensions#tabline#enabled = 1

      let mapleader = " "

      " Remap y in visual mode to yank to unnamed register AND pipe that to https://github.com/Slackadays/clipboard
      " This makes yank copy to the system clipboard on all platforms, even via ssh
      function! CopyUnnamedRegisterToClipboard()
        call system('cb copy', @")
        if v:shell_error != 0
          echohl ErrorMsg
          echo "Error: `cb copy` failed with exit code " . v:shell_error
        else
          echohl InfoMessage
          echo "Successfully copied " . strlen(@") . " chars to system clipboard!"
        endif
        echohl None
      endfunction

      vnoremap y y:call CopyUnnamedRegisterToClipboard()<CR>

      " Also map Ctrl+C to copy for easier mouse interaction (Cmd+C (<D-c>) is caught by the terminal emulator)
      vnoremap <C-c> y:call CopyUnnamedRegisterToClipboard()<CR>

      " Make y in normal mode (suffixed by motions) yank to system clipboard as well
      function! YankMotionToClipboard(type)
        exec 'normal! `[v`]y'
        call CopyUnnamedRegisterToClipboard()
      endfunction

      nmap <silent> y :set opfunc=YankMotionToClipboard<CR>g@
    '';
  };
})
