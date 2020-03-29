#!/bin/bash

cd $HOME

git clone --bare 'https://github.com/iFreilicht/.dotfiles.git' .dotfiles/.git

# Set up git alias for working with special dotfile repo structure
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/.git/ --work-tree=$HOME'

# Include .gitconfig file when working with dotfiles
dot config --local include.path $HOME/.dotfiles/.gitconfig

if [ ! $1 == '--force'] then
    # Try to checkout all files
    dot checkout
    if [ $? != 0 ] then
        'Do what git says or re-run with --force.'
else
    # Checkout all files, overwriting exisiting ones
    dot checkout -f
fi
