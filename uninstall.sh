source ./config.sh

_remove_dotfiles "$HOME/dotfiles"
_remove_packages "${__PACKAGES[@]}"
_remove_directories "${__DIRS[@]}"
_remove_cargo_packages "${__CARGO_PACKAGES[@]}"
_remove_rust "$HOME/Repos"
_clean_packages
