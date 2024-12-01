#!/bin/zsh 

# Set directory paths
CONFIG_DIR="$HOME/.config"
CURRENT_DIR="$PWD"

echo "Moving all folders from ${CURRENT_DIR} to ${CONFIG_DIR}"

for ITEM in "$CURRENT_DIR"/*; do
    if [ -d "$ITEM" ]; then
        FOLDER=$(basename "$ITEM")
        echo "Copying $FOLDER to $CONFIG_DIR"
        cp -r "$ITEM" "$CONFIG_DIR/"
    fi
done

echo "all dotfiles copied, lets goooo"
