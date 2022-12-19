# Stuff to checkout

https://github.com/xwmx/bash-boilerplate/blob/master/bash-subcommands
https://github.com/xwmx/bash-boilerplate
https://bertvv.github.io/cheat-sheets/Bash.html
https://github.com/bats-core/bats-core

# List of TODOS 
 --- 

# TODO
# Look into using the correct package managers here and not this janky command
function is_installed {
  [ -n "$(command -v "$1")" ]
--
# TODO
# Group apt installs when everything is done
# Maybe look into rolling up a docker instance so that I can test the installation scripts
# Move different conditionals out to reusable functions
--
# TODO
# Probably will need to check which version is available and it compile from
# source if we can't find the correct one.
install_package neovim
--
# TODO
# Switch to zsh without having to restart prompt or maybe have a std option to
# manually reload after the script is finished.
# Issue here with switching to zsh
--
# TODO
# I should look into installing alg deps in a single go, but in first run let's
# just do them sequentially.
install_package kitty 
--
# TODO
# Do a more indepth look into this libs I use
# Need to look into bat/batcat a bit as well or how to manage aliases on
# different OS'es
--
# TODO
# Might be good to use a prompt for choosing if we should install certain tools
# like this, incase they're not required.
# install_package awscli 
--
# TODO
# Write a script that when it finds .nvmrc it uses pnpm to install correct node version
# https://dev.to/rennycat/pnpm-can-manage-nodejs-version-like-nvm--2ec0
# pnpm might not support 32bit enviroments.
--
# TODO
# Issue here with rust installation
# if [[ "$(which rustup | grep 'not found')" -eq '' ]]; then
#     curl --insecure --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#     # TODO
#     # Not sure if this works
#     # Resource to get access to cargo
#     # source ~/.zshrc
--
# TODO
# Setup vim

# Install stow, clone dotfiles repo and setup dotfiles.
# TODO
if is_directory "$DOTFILES_DIR"; then
  print_info "Already created ${DOTFILES_DIR}"
else
--
# TODO
# Remove pnpm
# pnpm rm --global pnpm

# TODO
# Remove rust
# rustup self uninstall

--
# TODO
# Update on other os
sudo apt-get update
sudo apt-get upgrade
--
# TODO
# Update node version relink packages if required update node and npm/pnpm
# Also look into updating nvim plugins and tmux plugins in this update
