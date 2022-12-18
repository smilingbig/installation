# Remove packages

echo 'My home directory is'
echo "$HOME"
printf '\n'

export DOTFILES_DIR="$HOME/dotfiles"
export ZSH_PLUGIN_DIR="$HOME/.zsh"
export PROJECTS_DIR="$HOME/Repos/"

sudo apt-get remove -y git neovim zsh kitty ripgrep bat shellcheck docker htop \
                       jq python3 ripgrep wget curl awscli gcc-multilib 

# Remove pnpm
pnpm rm --global pnpm

# Remove rust
rustup self uninstall

# Set bash as main shell
chsh --newshell "$(which bash)"

rmdir "$ZSH_PLUGIN_DIR"
rmdir "$PROJECTS_DIR"

# Unstow packages and delete dotfiles
cd "$DOTFILES_DIR" || exit

for d in * ; do
  [ -d "${d}" ] && stow --delete "${d}"
done

rmdir "$DOTFILES_DIR"

sudo apt-get remove -y stow
