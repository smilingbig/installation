#!/bin/bash

source ./config.sh

_update_packages
_update_repos "$HOME/.zsh" "${__ZSH_PLUGINS[@]}"
_update_dotfiles "$HOME/dotfiles"
_update_rust
_update_nvim_plugins
_update_tmux_plugins
_update_pnpm
