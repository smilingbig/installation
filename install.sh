#!/bin/bash 

function install_package {
	local pkg=$1
	
	if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		tput setaf 2
		echo -e "Installing $pkg."
		tput sgr0
		sudo apt install -y $pkg
	else
		tput setaf 3
		echo -e "$pkg already installed, skipping."
		tput sgr0
	fi
}

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
install_package git

# Install Nvim
# TODO
# Probably will need to check which version is available and it compile from
# source if we can't find the correct one.
install_package neovim

# Install zsh
# TODO 
# Check which OS for package manager.
install_package zsh

# Set zsh as main prompt
# TODO
# Switch to zsh without having to restart prompt or maybe have a std option to
# manually reload after the script is finished.
if [$SHELL = "/usr/bin/zsh"]; then
	tput setaf 3
	echo -e "Already using zsh."
	tput sgr0
else
	chsh -s $(which zsh)
fi

# Create .zsh directory for plugins
if [-d $ZSH_PLUGIN_DIR]; then
	tput setaf 3
	echo -e "Already created ${ZSH_PLUGIN_DIR}"
	tput sgr0
else
	mkdir $ZSH_PLUGIN_DIR
fi

# Zsh plugins
# TODO
# This should be setup to clone the repos if folders don't exist and to
# update them if they do
# Actually I'm thinking to have a different script for updating and isntalling
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGIN_DIR/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_PLUGIN_DIR/zsh-history-substring-search
git clone https://github.com/sindresorhus/pure.git "$ZSH_PLUGIN_DIR/pure"

# Didn't want to pull in entire repo, just grab git and nvm plugins
# TODO
# Set this up to fetch from a list and update
# Unfortunately this doesn't work because the git plugin is using global functions.
# I'll have to set it up to fetch certain pages in the correct structure with the required bits.
mkdir $HOME/.zsh/git
curl -o $HOME/.zsh/git/git.plugin.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh 

# Install kitty
# TODO
# I should look into installing all deps in a single go, but in first run let's
# just do them sequentially.
install_package kitty 

# Other installs
# TODO
# Do a more indepth look into this libs I use
# Need to look into bat/batcat a bit as well or how to manage aliases on
# different OS'es
install_package bat ripgrep

# Install pnpm for node management
# TODO
# Write a script that when it finds .nvmrc it uses pnpm to install correct node version
# https://dev.to/rennycat/pnpm-can-manage-nodejs-version-like-nvm--2ec0
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install Tmux
# TODO
# Need to setup tmux conf
install_package tmux

# Install rustup
# Needed to install gcc-multilib to get support for rust compilation
install_package gcc-multilib
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# TODO
# Not sure if this works
# Resource to get access to cargo
source ~/.zshrc

# Install git-delta via cargo
cargo install git-delta

# TODO
# Next things to install
# Setup vim
# Check if kitty settings are working
# Setup up tmux
# Install pure prompt

# Install stow, clone dotfiles repo and setup dotfiles.
# TODO
# Little install script I wrote for automatically setting up stowed dotfiles,
# probably needs testing
# This is not currently working though, I think because we ls a folder and
# maybe we need to cd into that folder isntead when stowing
git clone $DOTFILES_REPO $DOTFILES_DIR
install_package stow 
cd $DOTFILES_DIR
"ls" | grep --invert-match "\.git" | xargs -I{} stow {}
