#!/bin/bash 

# TODO
# Create the dotfiles repo, probably should look into maybe a branch for each
# operating system where required.
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_REPO="github.repo/etc"

# Install zsh
# TODO 
# Check which OS for package manager.
sudo apt update
sudo apt install -y zsh 

# Set zsh as main prompt
# TODO
# Switch to zsh without having to restart prompt or maybe have a std option to
# manually reload after the script is finished.
chsh -s $(which zsh)

# Install kitty
# TODO
# I should look into installing all deps in a single go, but in first run let's
# just do them sequentially.
sudo apt install -y kitty 

# Install stow, clone dotfiles repo and setup dotfiles.
git clone $DOTFILES_REPO $DOTFILES_DIR
sudo apt install -y stow 
stow $DOTFILES_DIR
