#!/bin/bash 

# TODO
# Create the dotfiles repo, probably should look into maybe a branch for each
# operating system where required.
# It'd be good if we could either setup ssh automatically or require it be
# setup as a dep of this install script. Could possibly auth git github to see
# if it's setup or something like that.
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_REPO="git@github.com:smilingbig/.dotfiles.git"
export PROJECTS_DIR="$HOME/Repos/"
export ZSH_PLUGIN_DIR="$HOME/.zsh"

# Install Git
# TODO
# Set this up to pull in required repos into, I should probably move this
# script to gists to use directly with curl and sh
sudo apt update
sudo apt install -y git

# Install Nvim
# TODO
# Probably will need to check which version is available and it compile from
# source if we can't find the correct one.
sudo apt install -y neovim

# Install zsh
# TODO 
# Check which OS for package manager.
sudo apt install -y zsh

# Set zsh as main prompt
# TODO
# Switch to zsh without having to restart prompt or maybe have a std option to
# manually reload after the script is finished.
chsh -s $(which zsh)

# Create .zsh directory for plugins
mkdir $ZSH_PLUGIN_DIR

# Zsh plugins
# TODO
# This should be setup to clone the repos if folders don't exist and to
# update them if they do
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGIN_DIR/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_PLUGIN_DIR/zsh-history-substring-search

# Didn't want to pull in entire repo, just grab git and nvm plugins
# TODO
# Set this up to fetch from a list and update
mkdir $HOME/.zsh/git
curl -o $HOME/.zsh/git/git.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh 

# Install kitty
# TODO
# I should look into installing all deps in a single go, but in first run let's
# just do them sequentially.
sudo apt install -y kitty 

# Other installs
# TODO
# Do a more indepth look into this libs I use
sudo apt install -y bat ripgrep

# Install pnpm for node management
# TODO
# Write a script that when it finds .nvmrc it uses pnpm to install correct node version
# https://dev.to/rennycat/pnpm-can-manage-nodejs-version-like-nvm--2ec0
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install Tmux
# TODO
# Need to setup tmux conf
sudo apt install -y tmux

# TODO
# Next things to install
# Setup rust
# Install git-delta with cargo
# Setup vim
# Check if kitty settings are working
# Setup up tmux
# Install pure prompt

# Install stow, clone dotfiles repo and setup dotfiles.
# TODO
# It looks like stow needs to be setup with each folder inside of repo and not
# just all of the folders, so either need to figure out how people are doing
# that, or need to loop files in top level of dotfiles repo and call stow on
# each
git clone $DOTFILES_REPO $DOTFILES_DIR
sudo apt install -y stow 
# stow $DOTFILES_DIR
