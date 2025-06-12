export ZSH="$HOME/.oh-my-zsh"

# Flutter path
# export PATH=$HOME/Developer/flutter/bin:$PATH

# Doom emacs path
# export PATH=$HOME/.emacs.d/bin:$PATH

# API Keys
export ANTHROPIC_API_KEY=""
export GEMINI_API_KEY=""
export OPENAI_API_KEY=""

ZSH_THEME="geoffgarside"

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias g="lazygit"
alias t="tmux"
alias y="yazi"
alias vim="nvim"
alias v="nvim"

# key repeat rate
# xset r rate 350 40

# icloud school alias
# alias school='cd /Users/rv/Library/Mobile\ Documents/com~apple~CloudDocs/school'
# add symlink: ln -s /Users/rv/Library/Mobile\ Documents/com~apple~CloudDocs/school 

# atuin zoxide sdkman
