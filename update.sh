source ./config.sh

_update_packages
_update_repos "$HOME/.zsh" "${__ZSH_PLUGINS[@]}"
_update_dotfiles "$HOME/dotfiles"
