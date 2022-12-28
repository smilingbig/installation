source ./config.sh

_update_packages
_install_packages "${__PACKAGES[@]}"
_make_directories "${__DIRS[@]}"
_clone_repos "$HOME/.zsh" "${__ZSH_PLUGINS[@]}"
_configure_dotfiles "$HOME/dotfiles" "https://github.com/smilingbig/.dotfiles.git"
