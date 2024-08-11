#!/bin/zsh

CONFIG_DIR="$HOME/.config"
REPO_DIR="$HOME/repos/dotfiles/config/"

TARGET_DIR="${1:-$REPO_DIR}"

FOLDERS=(kitty nvim skhd yabai)

echo "Moving folders from ${CONFIG_DIR} to ${TARGET_DIR}"

# Move the specified folders
for FOLDER in "${FOLDERS[@]}"; do
    if [ -d "$CONFIG_DIR/$FOLDER" ]; then
        echo "Moving $FOLDER to $REPO_DIR"
        cp -r "$CONFIG_DIR/$FOLDER" "$TARGET_DIR/"
    else
        echo "Folder $FOLDER does not exist in $CONFIG_DIR"
    fi
done

echo "Done."
