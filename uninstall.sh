source ./config.sh

_remove_dotfiles "$HOME/dotfiles"
_remove_packages "${__PACKAGES[@]}"
_remove_directories "${__DIRS[@]}"
_clean_packages
