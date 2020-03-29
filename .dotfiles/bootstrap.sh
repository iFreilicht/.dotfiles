#!/bin/bash

on_error () {
    echo "Error, cleaning up..."
    rm -rf "$HOME/.dotfiles"
    exit 1
}

# Cleanup on errors
trap 'on_error' ERR

cd $HOME

git clone --bare 'https://github.com/iFreilicht/.dotfiles.git' .dotfiles/.git

# Set up git alias for working with special dotfile repo structure
shopt -s expand_aliases
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/.git/ --work-tree=$HOME'

# Include .gitconfig file when working with dotfiles
dot config --local include.path $HOME/.dotfiles/.gitconfig

if [ ! $1 ] || [ $1 != '--force' ]; then
    # Try to checkout all files
    dot checkout
else
    # Checkout all files, overwriting exisiting ones
    dot checkout -f
fi
