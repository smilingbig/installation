#!/bin/bash 

# TODO
# Update on other os
sudo apt update
sudo apt upgrade

# Update ZSH plugins
# TODO
# I should set this up as a loop
# Also it would maybe be cool if I setup a way to just add the repos and
# destination directories and they got setup from a single place
# Zsh plugins
cd "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" || exit
git pull origin main

cd "$ZSH_PLUGIN_DIR/zsh-history-substring-search" || exit
git pull origin main

cd "$ZSH_PLUGIN_DIR/pure" || exit
git pull origin main

# Update rust/cargo
rustup update

# TODO
# Update node version relink packages if required update node and npm/pnpm
