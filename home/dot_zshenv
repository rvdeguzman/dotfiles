[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Required by non-interactive SSH sessions on this machine.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -r "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

typeset -U path PATH
path=("$HOME/bin" "$HOME/.local/bin" $path)
