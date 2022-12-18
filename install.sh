#!/bin/bash 

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_REPO="https://github.com/smilingbig/.dotfiles.git"
export PROJECTS_DIR="$HOME/Repos/"
export ZSH_PLUGIN_DIR="$HOME/.zsh"

function print_info {
  green='\033[0;32m'
  clear='\033[0m'
  echo -e "\n${green}${1}${clear}\n" 
}

function is_installed {
  [ "$(command -v "$1")" ]
}

function is_zshshell {
  [ "$(echo "$SHELL" | grep -c 'zsh')" -gt "1" ]
}

function is_directory {
  ! [ -d "$1" ]
}

function setup_stow {
  declare prevpwd
  prevpwd=$(pwd)

  cd "$DOTFILES_DIR" || exit

  print_line "Setup stow"

  for d in * ; do
    if is_directory "${d}"; then 
      print_line "Setting up dotfiles for ${d}"
      stow "${d}"
    fi
  done

  cd "$prevpwd" || exit
}

function install_package {
	local pkg=$1
	
  if ! [ "$(is_installed "$pkg")" ]; then
    print_info "Installing $pkg."
		sudo apt install -y "$pkg"
	else
    print_info "$pkg already installed, skipping."
	fi
}

# TODO
# Group apt installs when everything is done
# Maybe look into rolling up a docker instance so that I can test the installation scripts
# Move different conditionals out to reusable functions
# Move colour logging out to reusable fns

# Install Git
sudo apt update
install_package git

# Install Nvim
# TODO
# Probably will need to check which version is available and it compile from
# source if we can't find the correct one.
install_package neovim

# Install zsh
install_package zsh

# Set zsh as main prompt
# TODO
# Switch to zsh without having to restart prompt or maybe have a std option to
# manually reload after the script is finished.
# Issue here with switching to zsh

if is_zshshell; then
  print_info "Already using zsh."
else
	chsh -s "$(which zsh)"
fi

# Directory not being created
# Create .zsh directory for plugins
if is_directory "$ZSH_PLUGIN_DIR"; then
  print_info "Already created ${ZSH_PLUGIN_DIR}"
else
	mkdir "$ZSH_PLUGIN_DIR"
fi

# Make projects directory
if is_directory "$PROJECTS_DIR"; then
  print_info "Already created ${PROJECTS_DIR}"
else
	mkdir "$PROJECTS_DIR"
fi

# Zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_PLUGIN_DIR/zsh-history-substring-search"
git clone https://github.com/sindresorhus/pure.git "$ZSH_PLUGIN_DIR/pure"

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
install_package ripgrep
install_package bat 
install_package shellcheck 
install_package docker 
install_package htop 
install_package jq 
install_package python3
install_package wget
install_package curl

# AWS related installs
# TODO
# Might be good to use a prompt for choosing if we should install certain tools
# like this, incase they're not required.
# install_package awscli 

# Install pnpm for node management
# TODO
# Write a script that when it finds .nvmrc it uses pnpm to install correct node version
# https://dev.to/rennycat/pnpm-can-manage-nodejs-version-like-nvm--2ec0
# pnpm might not support 32bit enviroments.
# sudo curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install Tmux
# And setup tmux plugin manager
install_package tmux
# Install tpm for managing tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install rustup
# Needed to install gcc-multilib to get support for rust compilation on older laptop
install_package gcc-multilib

# TODO
# Issue here with rust installation
# if [[ "$(which rustup | grep 'not found')" -eq '' ]]; then
#     curl --insecure --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#     # TODO
#     # Not sure if this works
#     # Resource to get access to cargo
#     # source ~/.zshrc

#     # Install git-delta via cargo
#     cargo install git-delta
#   else
# 		tput setaf 3
# 		echo -e "$pkg already installed, skipping."
# 		tput sgr0
# fi

# TODO
# Setup vim

# Install stow, clone dotfiles repo and setup dotfiles.
# TODO
if is_directory "$DOTFILES_DIR"; then
  print_info "Already created ${DOTFILES_DIR}"
else
	mkdir "$DOTFILES_DIR"
fi

git clone $DOTFILES_REPO "$DOTFILES_DIR"
install_package stow 

setup_stow 

sudo apt-get autoremove
sudo apt-get clean
sudo apt-get autoclean

print_info "Things installed."
