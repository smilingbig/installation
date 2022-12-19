#!/bin/bash 

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

export PROJECTS_DIR="$HOME/Repos/"
export ZSH_PLUGIN_DIR="$HOME/.zsh"

# TODO
# Update on other os
sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get clean
sudo apt-get autoclean

# Update all zsh plugins in ZSH_PLUGIN_DIR
for d in "$ZSH_PLUGIN_DIR"/* ; do
  [ -d "${d}" ] && git --git-dir="${d}"/.git --work-tree="${d}" pull
done

# Update all git repos in PROJECTS_DIR
for d in "$PROJECTS_DIR"/* ; do
  [ -d "${d}" ] && git --git-dir="${d}"/.git --work-tree="${d}" pull
done

# Update rust/cargo
# rustup update

# TODO
# Update node version relink packages if required update node and npm/pnpm
# Also look into updating nvim plugins and tmux plugins in this update
