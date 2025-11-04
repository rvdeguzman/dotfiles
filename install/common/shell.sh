#!/bin/bash

# Common shell setup functions

# Function to install Oh My Zsh
install_ohmyzsh() {
    echo "Installing Oh My Zsh..."
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "✓ Oh My Zsh already installed"
        return
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
}

# Function to change default shell to zsh
set_zsh_as_default() {
    echo "Setting zsh as default shell..."
    
    # Get the path to zsh
    local zsh_path=$(command -v zsh)
    if [[ -z "$zsh_path" ]]; then
        echo "Error: zsh is not installed!"
        return 1
    fi
    
    # Check if zsh is already the default shell
    if [[ "$SHELL" == "$zsh_path" ]]; then
        echo "✓ zsh is already the default shell"
        return
    fi
    
    # Change default shell
    chsh -s "$zsh_path"
    echo "✓ Default shell changed to zsh"
    echo ""
    echo "Note: You may need to log out and log back in for the shell change to take effect."
}

# Function to setup both zsh and Oh My Zsh
setup_shell() {
    install_ohmyzsh
    echo ""
    set_zsh_as_default
}
