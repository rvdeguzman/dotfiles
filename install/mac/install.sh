#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages.txt"
CHOICE="${1:-}"

show_usage() {
    echo "macOS Setup - Package Installation"
    echo ""
    echo "Usage: $0 [base|full|help]"
    echo ""
    echo "Options:"
    echo "  base - Install base packages only"
    echo "  full - Install all packages (base + casks + mac-dev)"
    echo "  help - Show this message"
    echo ""
    echo "If no argument provided, will prompt for choice."
    exit 1
}

# Function to install Xcode Command Line Tools if not already installed
install_xcode_tools() {
    if xcode-select -p &> /dev/null; then
        echo "✓ Xcode Command Line Tools already installed"
        return
    fi
    
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for installation to complete
    while ! xcode-select -p &> /dev/null; do
        echo "Waiting for Xcode Command Line Tools installation to complete..."
        sleep 5
    done
    
    echo "✓ Xcode Command Line Tools installed"
}

# Function to install Homebrew if not already installed
install_homebrew() {
    if command -v brew &> /dev/null; then
        echo "✓ Homebrew already installed"
        return
    fi
    
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    echo "✓ Homebrew installed successfully"
}

# Function to verify Homebrew is available
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew installation failed or is unavailable!"
        exit 1
    fi
    echo "✓ Homebrew is available"
}

# Function to install packages
install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        echo "No packages to install."
        return
    fi
    
    echo ""
    echo "→ Installing ${#packages[@]} packages with Homebrew..."
    brew install --quiet "${packages[@]}"
    echo "✓ Installation complete!"
}

# Function to install casks
install_casks() {
    local casks=("$@")
    if [ ${#casks[@]} -eq 0 ]; then
        echo "No casks to install."
        return
    fi
    
    echo ""
    echo "→ Installing ${#casks[@]} casks with Homebrew..."
    brew install --cask --quiet "${casks[@]}"
    echo "✓ Cask installation complete!"
}

# Function to parse packages from file
parse_packages() {
    local choice="$1"
    local base_packages=()
    local cask_packages=()
    local mac_dev_packages=()
    local current_section="base"
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check for section headers
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            section=$(echo "$line" | tr -d '[]' | tr '[:upper:]' '[:lower:]')
            case "$section" in
                "base") current_section="base" ;;
                "casks") current_section="casks" ;;
                "mac-dev") current_section="mac-dev" ;;
                *) current_section="base" ;;
            esac
            continue
        fi
        
        # Add package to appropriate array
        case "$current_section" in
            "base") base_packages+=("$line") ;;
            "casks") cask_packages+=("$line") ;;
            "mac-dev") mac_dev_packages+=("$line") ;;
        esac
    done < "$PACKAGES_FILE"
    
    # Install based on choice
    case "$choice" in
        "base")
            echo "Installing base packages..."
            install_packages "${base_packages[@]}"
            ;;
        "full")
            echo "Installing all packages (base + casks + mac-dev)..."
            install_packages "${base_packages[@]}" "${mac_dev_packages[@]}"
            install_casks "${cask_packages[@]}"
            ;;
        *)
            echo "Invalid choice: $choice"
            return 1
            ;;
    esac
}

# Main script
main() {
    echo "================================================"
    echo "   macOS System Setup"
    echo "================================================"
    echo ""
    
    # Check if packages file exists
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        echo "Error: $PACKAGES_FILE not found!"
        exit 1
    fi
    
    # Install dependencies
    install_xcode_tools
    echo ""
    install_homebrew
    echo ""
    
    # Verify dependencies are available
    check_homebrew
    echo ""
    
    # Get choice if not provided
    if [[ -z "$CHOICE" ]]; then
        echo "Select installation type:"
        echo ""
        echo "  1) base (base packages only)"
        echo "  2) full (all packages: base + casks + mac-dev)"
        echo "  3) quit"
        echo ""
        read -p "Enter choice (1-3): " choice_num
        
        case "$choice_num" in
            1) CHOICE="base" ;;
            2) CHOICE="full" ;;
            3) echo "Exiting."; exit 0 ;;
            *) echo "Invalid choice."; exit 1 ;;
        esac
    fi
    
    # Validate choice
    case "$CHOICE" in
        "base"|"full") ;;
        "help"|"-h"|"--help") show_usage ;;
        *) echo "Invalid choice: $CHOICE"; show_usage ;;
    esac
    
    echo ""
    parse_packages "$CHOICE"
    echo ""
    echo "================================================"
    echo "   Setup complete!"
    echo "================================================"
    echo ""
    echo "Note: You may want to run the following to ensure"
    echo "Homebrew is in your PATH:"
    echo ""
    echo "  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
}

main "$@"
