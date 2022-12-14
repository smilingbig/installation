#!/bin/bash 

sudo apt update
sudo apt upgrade

# Update ZSH plugins
# TODO
# I should set this up as a loop
# Zsh plugins
cd "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" || exit
git pull origin main

cd "$ZSH_PLUGIN_DIR/zsh-history-substring-search" || exit
git pull origin main

cd "$ZSH_PLUGIN_DIR/pure" || exit
git pull origin main
