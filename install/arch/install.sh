#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages.txt"
CHOICE="${1:-}"
PACKAGE_MANAGER="paru"

show_usage() {
    echo "Arch Linux Setup - Package Installation"
    echo ""
    echo "Usage: $0 [i3|hyprland|both]"
    echo ""
    echo "Options:"
    echo "  i3       - Install base packages + i3 specific packages"
    echo "  hyprland - Install base packages + hyprland specific packages"
    echo "  both     - Install all packages (base + i3 + hyprland)"
    echo "  help     - Show this message"
    echo ""
    echo "If no argument provided, will prompt for choice."
    exit 1
}

# Function to install paru if not already installed
install_paru() {
    if command -v paru &> /dev/null; then
        echo "✓ Paru already installed"
        return
    fi
    
    echo "Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel
    
    # Clone and build paru
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    cd "$temp_dir"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    echo "✓ Paru installed successfully"
}

# Function to verify package manager is available
check_package_manager() {
    if command -v paru &> /dev/null; then
        PACKAGE_MANAGER="paru"
        echo "✓ Paru is available"
    else
        echo "Error: Paru installation failed or is unavailable!"
        exit 1
    fi
}

# Function to install packages
install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        echo "No packages to install."
        return
    fi
    
    echo ""
    echo "→ Installing ${#packages[@]} packages with $PACKAGE_MANAGER..."
    $PACKAGE_MANAGER -S --needed --noconfirm "${packages[@]}"
    echo "✓ Installation complete!"
}

# Function to parse packages from file
parse_packages() {
    local choice="$1"
    local base_packages=()
    local i3_packages=()
    local hyprland_packages=()
    local current_section="base"
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check for section headers
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            section=$(echo "$line" | tr -d '[]' | tr '[:upper:]' '[:lower:]')
            case "$section" in
                "base") current_section="base" ;;
                "i3") current_section="i3" ;;
                "hyprland") current_section="hyprland" ;;
                *) current_section="base" ;;
            esac
            continue
        fi
        
        # Add package to appropriate array
        case "$current_section" in
            "base") base_packages+=("$line") ;;
            "i3") i3_packages+=("$line") ;;
            "hyprland") hyprland_packages+=("$line") ;;
        esac
    done < "$PACKAGES_FILE"
    
    # Install based on choice
    case "$choice" in
        "i3")
            echo "Installing for i3 window manager..."
            install_packages "${base_packages[@]}" "${i3_packages[@]}"
            ;;
        "hyprland")
            echo "Installing for Hyprland..."
            install_packages "${base_packages[@]}" "${hyprland_packages[@]}"
            ;;
        "both")
            echo "Installing all packages (base + i3 + hyprland)..."
            install_packages "${base_packages[@]}" "${i3_packages[@]}" "${hyprland_packages[@]}"
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
    echo "   Arch Linux System Setup"
    echo "================================================"
    echo ""
    
    # Check if packages file exists
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        echo "Error: $PACKAGES_FILE not found!"
        exit 1
    fi
    
    # Install paru first
    install_paru
    echo ""
    
    # Verify paru is available
    check_package_manager
    echo ""
    
    # Get choice if not provided
    if [[ -z "$CHOICE" ]]; then
        echo "Select installation type:"
        echo ""
        echo "  1) i3 (base + i3 packages)"
        echo "  2) hyprland (base + hyprland packages)"
        echo "  3) both (all packages)"
        echo "  4) quit"
        echo ""
        read -p "Enter choice (1-4): " choice_num
        
        case "$choice_num" in
            1) CHOICE="i3" ;;
            2) CHOICE="hyprland" ;;
            3) CHOICE="both" ;;
            4) echo "Exiting."; exit 0 ;;
            *) echo "Invalid choice."; exit 1 ;;
        esac
    fi
    
    # Validate choice
    case "$CHOICE" in
        "i3"|"hyprland"|"both") ;;
        "help"|"-h"|"--help") show_usage ;;
        *) echo "Invalid choice: $CHOICE"; show_usage ;;
    esac
    
    echo ""
    parse_packages "$CHOICE"
    echo ""
    echo "================================================"
    echo "   Setup complete!"
    echo "================================================"
}

main "$@"
