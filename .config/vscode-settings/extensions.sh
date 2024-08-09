#!/bin/bash

# Default command to 'code'
CMD="code"

# Check if a parameter is provided and use it instead of 'code'
if [ "$1" ]; then
  CMD="$1"
fi

$CMD --install-extension aaron-bond.better-comments
$CMD --install-extension adpyke.codesnap
$CMD --install-extension alefragnani.bookmarks
$CMD --install-extension asvetliakov.vscode-neovim
$CMD --install-extension christian-kohler.path-intellisense
$CMD --install-extension drcika.apc-extension
$CMD --install-extension entuent.fira-code-nerd-font
$CMD --install-extension esbenp.prettier-vscode
$CMD --install-extension gruntfuggly.todo-tree
$CMD --install-extension jonathanharty.gruvbox-material-icon-theme
$CMD --install-extension sainnhe.gruvbox-material
$CMD --install-extension usernamehw.errorlens
$CMD --install-extension vspacecode.whichkey
