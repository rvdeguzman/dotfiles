#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_usage() {
    echo "Common Setup - Install cross-platform tools"
    echo ""
    echo "Usage: $0 [all|atuin|zoxide|ohmyzsh|sdkman|help]"
    echo ""
    echo "Options:"
    echo "  all     - Install all common tools"
    echo "  atuin   - Install Atuin (shell history)"
    echo "  zoxide  - Install Zoxide (smart cd)"
    echo "  ohmyzsh - Install Oh My Zsh"
    echo "  sdkman  - Install SDKMAN (Java SDK manager)"
    echo "  help    - Show this message"
    echo ""
    echo "If no argument provided, will prompt for choice."
    exit 1
}

# Atuin - shell history
install_atuin() {
    echo "Installing Atuin..."
    if command -v atuin &> /dev/null; then
        echo "✓ Atuin already installed"
        return
    fi
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    echo "✓ Atuin installed"
}

# Zoxide - smart cd
install_zoxide() {
    echo "Installing Zoxide..."
    if command -v zoxide &> /dev/null; then
        echo "✓ Zoxide already installed"
        return
    fi
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    echo "✓ Zoxide installed"
    echo ""
    echo "Add this to your .zshrc:"
    echo '  eval "$(zoxide init zsh)"'
}

# Oh My Zsh
install_ohmyzsh() {
    echo "Installing Oh My Zsh..."
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "✓ Oh My Zsh already installed"
        return
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
}

# SDKMAN - Java SDK manager
install_sdkman() {
    echo "Installing SDKMAN..."
    if [[ -d "$HOME/.sdkman" ]]; then
        echo "✓ SDKMAN already installed"
        return
    fi
    curl -s "https://get.sdkman.io" | bash
    echo "✓ SDKMAN installed"
    echo ""
    echo "Run this command to activate SDKMAN:"
    echo '  source "$HOME/.sdkman/bin/sdkman-init.sh"'
}

# Main function
main() {
    local choice="${1:-}"
    
    if [[ -z "$choice" ]]; then
        echo "Common Tools Setup"
        echo ""
        echo "Select tools to install:"
        echo ""
        echo "  1) all (all common tools)"
        echo "  2) atuin"
        echo "  3) zoxide"
        echo "  4) ohmyzsh"
        echo "  5) sdkman"
        echo "  6) quit"
        echo ""
        read -p "Enter choice (1-6): " choice_num
        
        case "$choice_num" in
            1) choice="all" ;;
            2) choice="atuin" ;;
            3) choice="zoxide" ;;
            4) choice="ohmyzsh" ;;
            5) choice="sdkman" ;;
            6) echo "Exiting."; exit 0 ;;
            *) echo "Invalid choice."; exit 1 ;;
        esac
    fi
    
    echo "================================================"
    echo "   Common Tools Setup"
    echo "================================================"
    echo ""
    
    case "$choice" in
        "all")
            install_atuin
            install_zoxide
            install_ohmyzsh
            install_sdkman
            ;;
        "atuin")
            install_atuin
            ;;
        "zoxide")
            install_zoxide
            ;;
        "ohmyzsh")
            install_ohmyzsh
            ;;
        "sdkman")
            install_sdkman
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            echo "Invalid choice: $choice"
            show_usage
            ;;
    esac
    
    echo ""
    echo "================================================"
    echo "   Setup complete!"
    echo "================================================"
}

main "$@"
