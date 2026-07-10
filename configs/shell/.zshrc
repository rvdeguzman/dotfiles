export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export EDITOR="${EDITOR:-nvim}"

# Keep secrets outside the repository.
unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN ANTHROPIC_AUTH_TOKEN
[[ -r "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

# zsh keeps PATH and path synchronized; -U removes duplicates.
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/go/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.opencode/bin"
  "$HOME/.maestro/bin"
  "$HOME/Developer/flutter/bin"
  "$HOME/.config/emacs/bin"
  "$HOME/.lmstudio/bin"
  "$PNPM_HOME/bin"
  $path
)

ZSH_THEME="geoffgarside"
plugins=(git)

if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

alias g="lazygit"
alias t="tmux"
alias y="yazi"
alias vim="nvim"
alias vi="nvim"
alias ogh="open-github"
alias mkvenv="python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
alias venv="source .venv/bin/activate"
alias tl='bash ~/.config/tmux/layout.sh'
alias cc="claude --dangerously-skip-permissions"
alias cls="clear"
alias h="herdr"
alias school='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/school"'
alias icloud='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs"'

export MAINICHI_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/mainichi"

[[ -r "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -r "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -r "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
[[ -r "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -r "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"

_ompair() {
  local chat="$1" advisor="$2"
  shift 2
  local config="${TMPDIR:-/tmp}/omp-pair-$$.yml"
  cat >"$config" <<YAML
advisor:
  enabled: true
defaultThinkingLevel: high
enabledModels:
  - anthropic/claude-opus-4-8
  - openai/gpt-5.5
modelRoles:
  default: ${chat}:high
  slow: anthropic/claude-opus-4-8:high
  advisor: ${advisor}:low
  smol: openai/gpt-5.5:low
  tiny: openai/gpt-5.5:low
YAML
  omp --config "$config" --models "claude-opus-4-8,gpt-5.5" "$@"
}

omo() { _ompair anthropic/claude-opus-4-8 openai/gpt-5.5 "$@"; }
omc() { _ompair openai/gpt-5.5 anthropic/claude-opus-4-8 "$@"; }

# Machine-only aliases and experiments belong here.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
