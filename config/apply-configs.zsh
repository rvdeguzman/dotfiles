#!/bin/zsh 

CONFIG_DIR="$HOME/.config"
CURRENT_DIR="$PWD"

FOLDERS=(kitty nvim skhd yabai)

echo "Moving folders from ${CURRENT_DIR} to ${CONFIG_DIR}"

# Move the specified folders
for FOLDER in "${FOLDERS[@]}"; do
    if [ -d "$PWD/$FOLDER" ]; then
        echo "Copying $FOLDER to $CONFIG_DIR"
        cp -r "$PWD/$FOLDER" "$CONFIG_DIR/"
    else
        echo "Folder $FOLDER does not exist in $CONFIG_DIR, making...."
    fi
done

echo "Done."
