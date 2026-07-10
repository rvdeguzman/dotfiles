if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi

[[ -d /Applications/Obsidian.app/Contents/MacOS ]] && path+=(/Applications/Obsidian.app/Contents/MacOS)
