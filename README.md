# Installation, update and removal scripts for my dev setup
Some scripts for setting up and updating development enviroment for debian.

# TODO
[] - Need to retest everything on debian
[x] - port to work on macos
[] - create a list of what failed to be displayed at end of execution
[x] - add in non development application required
[] - create an easy way to run the installation and update the readme
[] - alias the update command during installation
[] - setup pnpm to manage global node versions
[] - Setup zsh installing and rolling down
[] - Update commands to use their internal debug/verbose commands when debug is enabled eg: brew uninstall thing --debug
[] - add vim(packer) and tmux(tpm) updates/sync to update script
[] - remove brew on uninstall
[] - currently browsers hijack update functionality via brew, so they need to be force reinstalled, need to script that
[x] - Need to setup kitty colour scheme I guess dracula
[x] - Resolve issue with zsh highlighting
[x] - Maybe look into using zplug for zsh plugins otherwise just use oh my zsh
[x] - plugins directly for git aliases and also remove the custom git aliases I copied in, no point managing them myself
[] - Added zplug instead of manually installing plugins, so will need to remove the zsh plugin part of installation
[] - Stash changes before doing update in git repos and reapply them after update is done, or something along those lines. Essentially to allow update when there are changes that need commiting
[] - Add a pnpm remove script
[] - Add wikis
