#!/usr/bin/env bash
###############################################################################
#            _                                                   _
#  ___ _   _| |__   ___ ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
# / __| | | | '_ \ / __/ _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
# \__ \ |_| | |_) | (_| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
# |___/\__,_|_.__/ \___\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/
#
#
# Boilerplate for creating a bash program with subcommands.
#
# Depends on:
#  list
#  of
#  programs
#  expected
#  in
#  environment
#
# Bash Boilerplate: https://github.com/xwmx/bash-boilerplate
#
# Copyright (c) 2015 William Melody • hi@williammelody.com
###############################################################################

# Notes #######################################################################

# Extensive descriptions are included for easy reference.
#
# Explicitness and clarity are generally preferable, especially since bash can
# be difficult to read. This leads to noisier, longer code, but should be
# easier to maintain. As a result, some general design preferences:
#
# - Use leading underscores on internal variable and function names in order
#   to avoid name collisions. For unintentionally global variables defined
#   without `local`, such as those defined outside of a function or
#   automatically through a `for` loop, prefix with double underscores.
# - Always use braces when referencing variables, preferring `${NAME}` instead
#   of `$NAME`. Braces are only required for variable references in some cases,
#   but the cognitive overhead involved in keeping track of which cases require
#   braces can be reduced by simply always using them.
# - Prefer `printf` over `echo`. For more information, see:
#   http://unix.stackexchange.com/a/65819
# - Prefer `$_explicit_variable_name` over names like `$var`.
# - Use the `#!/usr/bin/env bash` shebang in order to run the preferred
#   Bash version rather than hard-coding a `bash` executable path.
# - Prefer splitting statements across multiple lines rather than writing
#   one-liners.
# - Group related code into sections with large, easily scannable headers.
# - Describe behavior in comments as much as possible, assuming the reader is
#   a programmer familiar with the shell, but not necessarily experienced
#   writing shell scripts.

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

###############################################################################
# Globals
###############################################################################

# $_ME
#
# This program's basename.
_ME="$(basename "${0}")"

_DOTFILES_REPO="https://github.com/smilingbig/.dotfiles.git"

# Add additional packages to install to the _PACKAGES array
_PACKAGES=(
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

_DIRS=(
  "$HOME/.zsh" # zsh plugin and config bits
  "$HOME/.tmux/plugins" # tmux plugins and config bits
  "$HOME/dotfiles" # dotfiles
  "$HOME/Repos" # Repository directory
)

_ZSH_PLUGINS=(
  "https://github.com/zsh-users/zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-history-substring-search"
  "https://github.com/sindresorhus/pure"
)

# $_VERSION
#
# Manually set this to to current version of the program. Adhere to the
# semantic versioning specification: http://semver.org
_VERSION="0.1.0-alpha"

# $DEFAULT_SUBCOMMAND
#
# The subcommand to be run by default, when no subcommand name is specified.
# If the environment has an existing $DEFAULT_SUBCOMMAND set, then that value
# is used.
DEFAULT_SUBCOMMAND="${DEFAULT_SUBCOMMAND:-help}"

###############################################################################
# Debug
###############################################################################

# _debug()
#
# Usage:
#   _debug <command> <options>...
#
# Description:
#   Execute a command and print to standard error. The command is expected to
#   print a message and should typically be either `echo`, `printf`, or `cat`.
#
# Example:
#   _debug printf "Debug info. Variable: %s\\n" "$0"
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

###############################################################################
# Error Messages
###############################################################################

# _exit_1()
#
# Usage:
#   _exit_1 <command>
#
# Description:
#   Exit with status 1 after executing the specified command with output
#   redirected to standard error. The command is expected to print a message
#   and should typically be either `echo`, `printf`, or `cat`.
_exit_1() {
  {
    printf "%s " "$(tput setaf 1)!$(tput sgr0)"
    "${@}"
  } 1>&2
  exit 1
}

# _warn()
#
# Usage:
#   _warn <command>
#
# Description:
#   Print the specified command with output redirected to standard error.
#   The command is expected to print a message and should typically be either
#   `echo`, `printf`, or `cat`.
_warn() {
  {
    printf "%s " "$(tput setaf 1)!$(tput sgr0)"
    "${@}"
  } 1>&2
}

###############################################################################
# Utility Functions
###############################################################################

# _function_exists()
#
# Usage:
#   _function_exists <name>
#
# Exit / Error Status:
#   0 (success, true) If function with <name> is defined in the current
#                     environment.
#   1 (error,  false) If not.
#
# Other implementations, some with better performance:
# http://stackoverflow.com/q/85880
_function_exists() {
  [ "$(type -t "${1}")" == 'function' ]
}

# _command_exists()
#
# Usage:
#   _command_exists <name>
#
# Exit / Error Status:
#   0 (success, true) If a command with <name> is defined in the current
#                     environment.
#   1 (error,  false) If not.
#
# Information on why `hash` is used here:
# http://stackoverflow.com/a/677212
_command_exists() {
  hash "${1}" 2>/dev/null
}

# _contains()
#
# Usage:
#   _contains <query> <list-item>...
#
# Exit / Error Status:
#   0 (success, true)  If the item is included in the list.
#   1 (error,  false)  If not.
#
# Examples:
#   _contains "${_query}" "${_list[@]}"
_contains() {
  local _query="${1:-}"
  shift

  if [[ -z "${_query}"  ]] ||
     [[ -z "${*:-}"     ]]
  then
    return 1
  fi

  for __element in "${@}"
  do
    [[ "${__element}" == "${_query}" ]] && return 0
  done

  return 1
}

# _join()
#
# Usage:
#   _join <delimiter> <list-item>...
#
# Description:
#   Print a string containing all <list-item> arguments separated by
#   <delimeter>.
#
# Example:
#   _join "${_delimeter}" "${_list[@]}"
#
# More information:
#   https://stackoverflow.com/a/17841619
_join() {
  local _delimiter="${1}"
  shift
  printf "%s" "${1}"
  shift
  printf "%s" "${@/#/${_delimiter}}" | tr -d '[:space:]'
}

# _blank()
#
# Usage:
#   _blank <argument>
#
# Exit / Error Status:
#   0 (success, true)  If <argument> is not present or null.
#   1 (error,  false)  If <argument> is present and not null.
_blank() {
  [[ -z "${1:-}" ]]
}

# _present()
#
# Usage:
#   _present <argument>
#
# Exit / Error Status:
#   0 (success, true)  If <argument> is present and not null.
#   1 (error,  false)  If <argument> is not present or null.
_present() {
  [[ -n "${1:-}" ]]
}

# _interactive_input()
#
# Usage:
#   _interactive_input
#
# Exit / Error Status:
#   0 (success, true)  If the current input is interactive (eg, a shell).
#   1 (error,  false)  If the current input is stdin / piped input.
_interactive_input() {
  [[ -t 0 ]]
}

# _piped_input()
#
# Usage:
#   _piped_input
#
# Exit / Error Status:
#   0 (success, true)  If the current input is stdin / piped input.
#   1 (error,  false)  If the current input is interactive (eg, a shell).
_piped_input() {
  ! _interactive_input
}

# _dir_present()
#
# Usage:
#   _dir_present <argument>
#
# Exit / Error Status:
#   0 (success, true)  If <argument> is present and not null.
#   1 (error,  false)  If <argument> is not present or null.
_dir_present() {
  [[ -d "${1:-}" ]]
}

# _install_packages()
#
# Usage:
#   _install_packages <package-name>...
#
function _install_packages {
  for p in "$@"
  do
    if ! _command_exists "${p}"; then
      _debug printf "Install package. Variable: %s\\n" "${p}"
      sudo apt install -y "${p}"
    else
      _debug printf "Package already installed. Variable: %s\\n" "${p}"
    fi
  done
}

###############################################################################
# describe
###############################################################################

# describe()
#
# Usage:
#   describe <name> <description>
#   describe --get <name>
#
# Options:
#   --get  Print the description for <name> if one has been set.
#
# Examples:
# ```
#   describe "list" <<HEREDOC
# Usage:
#   ${_ME} list
#
# Description:
#   List items.
# HEREDOC
#
# describe --get "list"
# ```
#
# Set or print a description for a specified subcommand or function <name>. The
# <description> text can be passed as the second argument or as standard input.
#
# To make the <description> text available to other functions, `describe()`
# assigns the text to a variable with the format `$___describe_<name>`.
#
# When the `--get` option is used, the description for <name> is printed, if
# one has been set.
#
# NOTE:
#
# The `read` form of assignment is used for a balance of ease of
# implementation and simplicity. There is an alternative assignment form
# that could be used here:
#
# var="$(cat <<'HEREDOC'
# some message
# HEREDOC
# )
#
# However, this form appears to require trailing space after backslases to
# preserve newlines, which is unexpected. Using `read` simply requires
# escaping backslashes, which is more common.
describe() {
  _debug printf "describe() \${*}: %s\\n" "$@"
  [[ -z "${1:-}" ]] && _exit_1 printf "describe(): <name> required.\\n"

  if [[ "${1}" == "--get" ]]
  then # get ------------------------------------------------------------------
    [[ -z "${2:-}" ]] &&
      _exit_1 printf "describe(): <description> required.\\n"

    local _name="${2:-}"
    local _describe_var="___describe_${_name}"

    if [[ -n "${!_describe_var:-}" ]]
    then
      printf "%s\\n" "${!_describe_var}"
    else
      printf "No additional information for \`%s\`\\n" "${_name}"
    fi
  else # set ------------------------------------------------------------------
    if [[ -n "${2:-}" ]]
    then # argument is present
      read -r -d '' "___describe_${1}" <<HEREDOC
${2}
HEREDOC
    else # no argument is present, so assume piped input
      # `read` exits with non-zero status when a delimeter is not found, so
      # avoid errors by ending statement with `|| true`.
      read -r -d '' "___describe_${1}" || true
    fi
  fi
}

###############################################################################
# Program Option Parsing
#
# NOTE: The `getops` builtin command only parses short options and BSD `getopt`
# does not support long arguments (GNU `getopt` does), so use custom option
# normalization and parsing.
#
# For a pure bash `getopt` function, try pure-getopt:
#   https://github.com/agriffis/pure-getopt
#
# More info:
#   http://wiki.bash-hackers.org/scripting/posparams
#   http://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html
#   http://stackoverflow.com/a/14203146
#   http://stackoverflow.com/a/7948533
#   https://stackoverflow.com/a/12026302
#   https://stackoverflow.com/a/402410
###############################################################################

# Normalize Options ###########################################################

# Source:
#   https://github.com/e36freak/templates/blob/master/options

# Iterate over options, breaking -ab into -a -b and --foo=bar into --foo bar
# also turns -- into --endopts to avoid issues with things like '-o-', the '-'
# should not indicate the end of options, but be an invalid option (or the
# argument to the option, such as wget -qO-)
unset options
# while the number of arguments is greater than 0
while ((${#}))
do
  case "${1}" in
    # if option is of type -ab
    -[!-]?*)
      # loop over each character starting with the second
      for ((i=1; i<${#1}; i++))
      do
        # extract 1 character from position 'i'
        c="${1:i:1}"
        # add current char to options
        options+=("-${c}")
      done
      ;;
    # if option is of type --foo=bar, split on first '='
    --?*=*)
      options+=("${1%%=*}" "${1#*=}")
      ;;
    # end of options, stop breaking them up
    --)
      options+=(--endopts)
      shift
      options+=("${@}")
      break
      ;;
    # otherwise, nothing special
    *)
      options+=("${1}")
      ;;
  esac

  shift
done
# set new positional parameters to altered options. Set default to blank.
set -- "${options[@]:-}"
unset options

# Parse Options ###############################################################

_SUBCOMMAND=""
_SUBCOMMAND_ARGUMENTS=()
_USE_DEBUG=0

while ((${#}))
do
  __opt="${1}"

  shift

  case "${__opt}" in
    -h|--help)
      _SUBCOMMAND="help"
      ;;
    --version)
      _SUBCOMMAND="version"
      ;;
    --debug)
      _USE_DEBUG=1
      ;;
    *)
      # The first non-option argument is assumed to be the subcommand name.
      # All subsequent arguments are added to $_SUBCOMMAND_ARGUMENTS.
      if [[ -n "${_SUBCOMMAND}" ]]
      then
        _SUBCOMMAND_ARGUMENTS+=("${__opt}")
      else
        _SUBCOMMAND="${__opt}"
      fi
      ;;
  esac
done

###############################################################################
# Main
###############################################################################

# Declare the $_DEFINED_SUBCOMMANDS array.
_DEFINED_SUBCOMMANDS=()

# _main()
#
# Usage:
#   _main
#
# Description:
#   The primary function for starting the program.
#
#   NOTE: must be called at end of program after all subcommands are defined.
_main() {
  # If $_SUBCOMMAND is blank, then set to `$DEFAULT_SUBCOMMAND`
  if [[ -z "${_SUBCOMMAND}" ]]
  then
    _SUBCOMMAND="${DEFAULT_SUBCOMMAND}"
  fi

  for __name in $(declare -F)
  do
    # Each element has the format `declare -f function_name`, so set the name
    # to only the 'function_name' part of the string.
    local _function_name
    _function_name=$(printf "%s" "${__name}" | awk '{ print $3 }')

    if ! { [[ -z "${_function_name:-}"                      ]] ||
           [[ "${_function_name}" =~ ^_(.*)                 ]] ||
           [[ "${_function_name}" == "bats_readlinkf"       ]] ||
           [[ "${_function_name}" == "describe"             ]] ||
           [[ "${_function_name}" == "shell_session_update" ]]
    }
    then
      _DEFINED_SUBCOMMANDS+=("${_function_name}")
    fi
  done

  # If the subcommand is defined, run it, otherwise return an error.
  if _contains "${_SUBCOMMAND}" "${_DEFINED_SUBCOMMANDS[@]:-}"
  then
    # Pass all comment arguments to the program except for the first ($0).
    ${_SUBCOMMAND} "${_SUBCOMMAND_ARGUMENTS[@]:-}"
  else
    _exit_1 printf "Unknown subcommand: %s\\n" "${_SUBCOMMAND}"
  fi
}

###############################################################################
# Default Subcommands
###############################################################################

# help ########################################################################

describe "help" <<HEREDOC
Usage:
  ${_ME} help [<subcommand>]

Description:
  Display help information for ${_ME} or a specified subcommand.
HEREDOC
help() {
  if [[ "${1:-}" ]]
  then
    describe --get "${1}"
  else
    cat <<HEREDOC
           _                                                   _
 ___ _   _| |__   ___ ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
/ __| | | | '_ \ / __/ _ \| '_ \` _ \\| '_ \` _ \ / _\` | '_ \\ / _\` / __|
\__ \ |_| | |_) | (_| (_) | | | | | | | | | | | (_| | | | | (_| \__ \\
|___/\__,_|_.__/ \___\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/


Boilerplate for creating a bash program with subcommands.

Version: ${_VERSION}

Usage:
  ${_ME} <subcommand> [--subcommand-options] [<arguments>]
  ${_ME} -h | --help
  ${_ME} --version

Options:
  -h --help  Display this help information.
  --version  Display version information.

Help:
  ${_ME} help [<subcommand>]

$(subcommands --)
HEREDOC
  fi
}

# subcommands #################################################################

describe "subcommands" <<HEREDOC
Usage:
  ${_ME} subcommands [--raw]

Options:
  --raw  Display the subcommand list without formatting.

Description:
  Display the list of available subcommands.
HEREDOC
subcommands() {
  if [[ "${1:-}" == "--raw" ]]
  then
    printf "%s\\n" "${_DEFINED_SUBCOMMANDS[@]}"
  else
    printf "Available subcommands:\\n"
    printf "  %s\\n" "${_DEFINED_SUBCOMMANDS[@]}"
  fi
}

# version #####################################################################

describe "version" <<HEREDOC
Usage:
  ${_ME} ( version | --version )

Description:
  Display the current program version.

  To save you the trouble, the current version is ${_VERSION}
HEREDOC
version() {
  printf "%s\\n" "${_VERSION}"
}

###############################################################################
# Subcommands
# ===========..................................................................
#
# Example subcommand group structure:
#
# describe example ""   - Optional. A short description for the subcommand.
# example() { : }   - The subcommand called by the user.
#
#
# describe example <<HEREDOC
#   Usage:
#     $_ME example
#
#   Description:
#     Print "Hello, World!"
#
#     For usage formatting conventions see:
#     - http://docopt.org/
#     - http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
# HEREDOC
# example() {
#   printf "Hello, World!\\n"
# }
#
###############################################################################

# Example Section #############################################################

# --------------------------------------------------------------------- example

describe "example" <<HEREDOC
Usage:
  ${_ME} example [<name>] [--farewell]

Options:
  --farewell  Print "Goodbye, World!"

Description:
  Print "Hello, World!"
HEREDOC
example() {
  local _arguments=()
  local _greeting="Hello"
  local _name=

  for __arg in "${@:-}"
  do
    case ${__arg} in
      --farewell)
        _greeting="Goodbye"
        ;;
      -*)
        _exit_1 printf "Unexpected option: %s\\n" "${__arg}"
        ;;
      *)
        if _blank "${_name}"
        then
          _name="${__arg}"
        else
          _arguments+=("${__arg}")
        fi
        ;;
    esac
  done


  if [[ "${_name}" == "Moon" ]]
  then
    printf "%s, Luna!\\n" "${_greeting}"
  elif [[ -n "${_name}" ]]
  then
    printf "%s, %s!\\n" "${_greeting}" "${_name}"
  else
    printf "%s, World!\\n" "${_greeting}"
  fi
}

describe "uninstall" <<HEREDOC
Usage:
  ${_ME} uninstall [<tags>]

Options:
  tags  pm dir stow

Description:
  Uninstall system
HEREDOC
uninstall() {
  local _arguments=()
  local _tags=

  for __arg in "${@:-}"
  do
    case ${__arg} in
      -*)
        _exit_1 printf "Unexpected option: %s\\n" "${__arg}"
        ;;
      *)
        if _blank "${_tags}"
        then
          # _tags="${__arg}"
          _tags="pm zsh git stow"
        else
          _arguments+=("${__arg}")
        fi
        ;;
    esac
  done

  if [[ "${_tags}" == *"stow"* ]]; then
    _debug printf "Deleting stow." 

    _debug printf "CDing into %s" "$HOME/dotfiles"

    cd "$HOME/dotfiles"

    for __dir in * ; do
      if _dir_present "${__dir}"; then 
        echo "${__dir}"
        _debug printf "Setting up dotfiles for: %s" "${__dir}"
        stow --delete "${__dir}"
      fi
    done

    if _dir_present "$HOME/dotfiles"; then
      _debug printf "Delete dotfiles folder."
      rm -fr "$HOME/dotfiles"
    fi

    sudo apt-get remove -y stow

    _debug printf "Stow completed."
  fi

  if [[ "${_tags}" == *"dir"* ]]; then
    _debug printf "Deleting directories \${*}: %s\\n." "${_DIRS[@]}"

    for __d in "${_DIRS[@]}"
    do
      rm -fr "$__dir"
    done

    _debug printf "Directories deleted." 
  fi

  if [[ "${_tags}" == *"pm"* ]]; then
    _debug printf "Removing packages \${*}: %s\\n." "${_PACKAGES[@]}"

    for __pkg in "${_PACKAGES[@]}"
    do
      sudo apt-get remove -y "$__pkg"
    done

    _debug printf "Packages removes." 
  fi
}

describe "update" <<HEREDOC
Usage:
  ${_ME} update [<tags>]

Options:
  tags  pm zsh git stow

Description:
  Update system
HEREDOC
update() {
  local _arguments=()
  local _tags=

  for __arg in "${@:-}"
  do
    case ${__arg} in
      -*)
        _exit_1 printf "Unexpected option: %s\\n" "${__arg}"
        ;;
      *)
        if _blank "${_tags}"
        then
          _tags="pm zsh git stow"
          # _tags="${__arg}"
        else
          _arguments+=("${__arg}")
        fi
        ;;
    esac
  done

  if [[ "${_tags}" == *"pm"* ]]; then
    _debug printf "Update, upgrade, autoremove, clean, autoclean"
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get autoremove
    sudo apt-get clean
    sudo apt-get autoclean
    _debug printf "PM update complete"
  fi

  if [[ "${_tags}" == *"zsh"* ]]; then
    _debug printf "Updating zsh repos"

    if ! _dir_present "$HOME/.zsh"; then
      _debug printf "Zsh plugin folder not found."
      _exit_1 printf "Zsh plugin folder not found."
    fi

    if ! _command_exists git; then
      _debug printf "Git required, installing now."
      _install_packages git
    fi

    for __zplugin in "${_ZSH_PLUGINS[@]}"
    do
      local targetPath
      targetPath="$HOME/.zsh/$(basename "${__zplugin}")"

      if _dir_present "${targetPath}"; then
        _debug printf "Updating %s at %s\\n" "${__zplugin}" "$targetPath"
        git --git-dir="${targetPath}"/.git --work-tree="${targetPath}" pull
      fi

    done
    _debug printf "Zsh plugins updated." 
  fi

  if [[ "${_tags}" == *"stow"* ]]; then
    _debug printf "Setting up stow." 
  
    if ! _dir_present "$HOME/dotfiles"; then
      _debug printf "Dotfiles folder required."
    fi

    if ! _command_exists git; then
      _debug printf "Git required, installing now."
      _install_packages git
    fi

    if ! _command_exists stow; then
      _debug printf "Stow required, installing now."
      _install_packages stow
    fi

    _debug printf "Updating %s at %s" "$_DOTFILES_REPO" "$HOME/dotfiles"
    git --git-dir="${HOME}/dotfiles"/.git --work-tree="${HOME}/dotfiles" pull

    cd "$HOME/dotfiles"

    for __dir in * ; do
      if _dir_present "${__dir}"; then 
        _debug printf "Restowing: %s" "${__dir}"
        stow --restow "${__dir}"
      fi
    done

    _debug printf "Stow updated."
  fi

  if [[ "${_tags}" == *"git"* ]]; then
    _debug printf "Updating git repos." 
  
    if ! _dir_present "$HOME/Repos"; then
      _debug printf "No Repos folder"
    fi

    if ! _command_exists git; then
      _debug printf "Git required, installing now."
      _install_packages git
    fi

    for __dir in "${HOME}"/Repos/* ; do
      _debug printf "Current: %s" "${__dir}"

      if _dir_present "${__dir}"; then 
        _debug printf "Updating: %s" "${__dir}"
        git --git-dir="${__dir}"/.git --work-tree="${__dir}" pull
      fi
    done

    _debug printf "Updated projects."
  fi
}

describe "install" <<HEREDOC
Usage:
  ${_ME} install [<tags>]

Options:
  tags  pm zsh dir stow

Description:
  Install all the things. Use tags to only run certain steps.
HEREDOC
install() {
  local _arguments=()
  # TODO
  # Not sure how to get this working atm, need to figure out how this loop is
  # working better 
  local _tags=

  for __arg in "${@:-}"
  do
    case ${__arg} in
      -*)
        _exit_1 printf "Unexpected option: %s\\n" "${__arg}"
        ;;
      *)
        if _blank "${_tags}"
        then
          _tags="pm dir zsh stow"
        else
          _arguments+=("${__arg}")
        fi

        ;;
    esac
  done

  _debug printf "Tags: %s\\n." "${_tags}"

  if [[ "${_tags}" == *"pm"* ]]; then
    _debug printf "Installing the following packages \${*}: %s\\n." "${_PACKAGES[@]}"

    for __pkg in "${_PACKAGES[@]}"
    do
      _install_packages "$__pkg"
    done

    _debug printf "Packages installed." 
  fi

  if [[ "${_tags}" == *"dir"* ]]; then
    _debug printf "Creating directories \${*}: %s\\n." "${_DIRS[@]}"

    for __d in "${_DIRS[@]}"
    do
      if ! _dir_present "${__d}"; then
        _debug printf "Creating directory %s\\n" "${__d}"
        mkdir -p "${__d}"
      else
        _debug printf "Directory exists %s\\n" "${__d}"
      fi
    done

    _debug printf "Directories created." 
  fi

  if [[ "${_tags}" == *"zsh"* ]]; then
    _debug printf "Cloning Zsh plugins \${*}: %s\\n." "${_ZSH_PLUGINS[@]}"

    if ! _dir_present "$HOME/.zsh"; then
      _debug printf ".zsh folder required to clone zsh plugins, creating it now."
      mkdir "$HOME/.zsh"
    fi

    if ! _command_exists git; then
      _debug printf "Git required, installing now."
      _install_packages git
    fi

    for __zplugin in "${_ZSH_PLUGINS[@]}"
    do
      local targetPath
      targetPath="$HOME/.zsh/$(basename "${__zplugin}")"

      if ! _dir_present "${targetPath}"; then
        _debug printf "Cloning %s into %s\\n" "${__zplugin}" "$targetPath"
        git clone "${__zplugin}" "${targetPath}"
      else
        _debug printf "Directory already exists %s" "$targetPath"
      fi

    done
    _debug printf "Zsh plugins installed." 
  fi
  
  if [[ "${_tags}" == *"stow"* ]]; then
    _debug printf "Setting up stow." 
  
    if ! _dir_present "$HOME/dotfiles"; then
      _debug printf "Dotfiles folder required to clone configs for stow, creating it now."
      mkdir "$HOME/dotfiles"
    fi

    if ! _command_exists git; then
      _debug printf "Git required, installing now."
      _install_packages git
    fi

    if ! _command_exists stow; then
      _debug printf "Stow required, installing now."
      _install_packages stow
    fi

    _debug printf "Cloning %s into %s" "$_DOTFILES_REPO" "$HOME/dotfiles"
    git clone $_DOTFILES_REPO "$HOME/dotfiles"

    _debug printf "CDing into %s" "$HOME/dotfiles"

    cd "$HOME/dotfiles"

    for __dir in * ; do
      if _dir_present "${__dir}"; then 
        _debug printf "Setting up dotfiles for: %s" "${__dir}"
        stow "${__dir}"
      fi
    done
    _debug printf "Stow completed."
  fi
}

###############################################################################
# Run Program
###############################################################################

# Call the `_main` function after everything has been defined.
_main
