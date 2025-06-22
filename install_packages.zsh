#!/bin/bash

PACKAGES_FILE="packages.txt"
CHOICE="${1:-}"
PACKAGE_MANAGER="paru"

show_usage() {
    echo "Usage: $0 [i3|hyprland|both]"
    echo "  i3       - Install base packages + i3 specific packages"
    echo "  hyprland - Install base packages + hyprland specific packages"
    echo "  both     - Install all packages"
    echo ""
    echo "If no argument provided, will prompt for choice."
    exit 1
}

# Function to check if paru is installed
check_paru() {
    if ! command -v paru &> /dev/null; then
        echo "Error: paru is not installed!"
        echo "Please install paru first:"
        echo "  git clone https://aur.archlinux.org/paru.git"
        echo "  cd paru && makepkg -si"
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
    
    echo "Installing packages with $PACKAGE_MANAGER: ${packages[*]}"
    $PACKAGE_MANAGER -S --needed "${packages[@]}"
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
                "base"|"common") current_section="base" ;;
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
            install_packages "${base_packages[@]}" "${i3_packages[@]}"
            ;;
        "hyprland")
            install_packages "${base_packages[@]}" "${hyprland_packages[@]}"
            ;;
        "both")
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
    # Check if paru is available
    check_paru
    
    # Check if packages file exists
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        echo "Error: $PACKAGES_FILE not found!"
        echo "Please create a packages.txt file in the current directory."
        exit 1
    fi
    
    # Get choice if not provided
    if [[ -z "$CHOICE" ]]; then
        echo "Select installation type:"
        echo "1) i3 (base + i3 packages)"
        echo "2) hyprland (base + hyprland packages)"
        echo "3) both (all packages)"
        echo "4) quit"
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
    
    echo "Installing packages for: $CHOICE"
    parse_packages "$CHOICE"
    echo "Installation complete!"
}

main "$@"
