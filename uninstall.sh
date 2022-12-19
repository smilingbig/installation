#!/bin/bash 

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

export DOTFILES_DIR="$HOME/dotfiles"
export ZSH_PLUGIN_DIR="$HOME/.zsh"
export PROJECTS_DIR="$HOME/Repos/"

sudo apt-get remove -y git neovim zsh kitty ripgrep bat shellcheck docker htop jq python3 ripgrep wget curl awscli gcc-multilib 

sudo apt-get autoremove
sudo apt-get clean
sudo apt-get autoclean

# TODO
# Remove pnpm
# pnpm rm --global pnpm

# TODO
# Remove rust
# rustup self uninstall

# Set bash as main shell
chsh -s "$(which bash)"

rm -fr "$ZSH_PLUGIN_DIR"
rm -fr "$PROJECTS_DIR"

# Unstow packages and delete dotfiles
cd "$DOTFILES_DIR" || exit

for d in * ; do
  [ -d "${d}" ] && stow --delete "${d}"
done

rm -fr "$DOTFILES_DIR"

sudo apt-get remove -y stow
