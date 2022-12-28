###############################################################################
# Strict Mode
###############################################################################

# Treat unset variables and parameters other than the special parameters ‘@’ or
# ‘*’ as an error when performing parameter expansion. An 'unbound variable'
# error message will be written to the standard error, and a non-interactive
# shell will exit.
#
# This requires using parameter expansion to test for unset variables.
#
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
#
# The two approaches that are probably the most appropriate are:
#
# ${parameter:-word}
#   If parameter is unset or null, the expansion of word is substituted.
#   Otherwise, the value of parameter is substituted. In other words, "word"
#   acts as a default value when the value of "$parameter" is blank. If "word"
#   is not present, then the default is blank (essentially an empty string).
#
# ${parameter:?word}
#   If parameter is null or unset, the expansion of word (or a message to that
#   effect if word is not present) is written to the standard error and the
#   shell, if it is not interactive, exits. Otherwise, the value of parameter
#   is substituted.
#
# Examples
# ========
#
# Arrays:
#
#   ${some_array[@]:-}              # blank default value
#   ${some_array[*]:-}              # blank default value
#   ${some_array[0]:-}              # blank default value
#   ${some_array[0]:-default_value} # default value: the string 'default_value'
#
# Positional variables:
#
#   ${1:-alternative} # default value: the string 'alternative'
#   ${2:-}            # blank default value
#
# With an error message:
#
#   ${1:?'error message'}  # exit with 'error message' if variable is unbound
#
# Short form: set -u
set -o nounset

# Exit immediately if a pipeline returns non-zero.
#
# NOTE: This can cause unexpected behavior. When using `read -rd ''` with a
# heredoc, the exit status is non-zero, even though there isn't an error, and
# this setting then causes the script to exit. `read -rd ''` is synonymous with
# `read -d $'\0'`, which means `read` until it finds a `NUL` byte, but it
# reaches the end of the heredoc without finding one and exits with status `1`.
#
# Two ways to `read` with heredocs and `set -e`:
#
# 1. set +e / set -e again:
#
#     set +e
#     read -rd '' variable <<HEREDOC
#     HEREDOC
#     set -e
#
# 2. Use `<<HEREDOC || true:`
#
#     read -rd '' variable <<HEREDOC || true
#     HEREDOC
#
# More information:
#
# https://www.mail-archive.com/bug-bash@gnu.org/msg12170.html
#
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

export __PACKAGES=(
  git
  neovim
  zsh
  kitty
  ripgrep
  bat
  shellcheck
  docker
  htop
  jq
  python3
  wget
  curl
  tmux
  stow
)

export __DIRS=(
  "$HOME/.zsh" # zsh plugin and config bits
  "$HOME/.tmux/plugins" # tmux plugins and config bits
  "$HOME/dotfiles" # dotfiles
  "$HOME/Repos" # Repository directory
)

export __ZSH_PLUGINS=(
  "https://github.com/zsh-users/zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-history-substring-search"
  "https://github.com/sindresorhus/pure"
)

export __TMUX_PLUGINS=()
export __CARGO_PLUGINS=()

__DEBUG_COUNTER=0
_debug() {
  if ((${_USE_DEBUG:-0}))
  then
    __DEBUG_COUNTER=$((__DEBUG_COUNTER+1))
    {
      # Prefix debug message with "bug (U+1F41B)"
      printf "💊 %s " "${__DEBUG_COUNTER}"
      "${@}"
      printf "―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――\\n"
    } 1>&2
  fi
}

_command_exists() {
  hash "${1}" 2>/dev/null
}

_dir_present() {
  [[ -d "${1:-}" ]]
}

_present() {
  [[ -n "${1:-}" ]]
}


_clean_packages() {
  _debug printf "Cleaning up unrequired deps"
  sudo apt-get autoremove
  sudo apt-get clean
  sudo apt-get autoclean
}

_update_packages() {
  _debug printf "Updating packages"
  sudo apt update
  trap _clean_packages EXIT
}

_install_packages() {
  for __p in "$@"
  do
    if ! _command_exists "${__p}"; then
      _debug printf "Installing %s \\n" "${__p}"
      sudo apt-get install -y "${__p}"
    else
      _debug printf "Package: %s already installed \\n" "${__p}"
    fi
  done
}

_remove_packages() {
  for __r in "$@"
  do
    if _command_exists "${__r}"; then
      _debug printf "Removing %s\\n" "${__r}"
      sudo apt-get remove -y "${__r}"
    else
      _debug printf "Package: %s wasn't installed \\n" "${__r}"
    fi
  done
}

_make_directories() {
  for __d in "$@"
  do
    if ! _dir_present "${__d}"; then
      _debug printf "Make dir: %s\\n" "${__d}"
      mkdir -p "${__d}"
    else
      _debug printf "Directory: %s already made \\n" "${__d}"
    fi
  done
}

_remove_directories() {
  for __d in "$@"
  do
    if _dir_present "${__d}"; then
      _debug printf "Removing: %s\\n" "${__d}"
      rm -fr "${__d}"
    else
      _debug printf "Directory: %s doesnt exist\\n" "${__d}"
    fi
  done
}

_clone_repos() {
  _make_directories "$1"

  for __c in $2
  do
    _debug printf "Cloning: %s into: %s \\n" "${__c}" "${1}"
    git clone "${__c}" "${1}"
  done
}

export _USE_DEBUG=1
