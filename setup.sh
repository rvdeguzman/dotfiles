#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_usage() {
    echo "System Setup Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --arch              Setup for Arch Linux"
    echo "  --mac               Setup for macOS"
    echo "  --common-only       Install only common cross-platform tools"
    echo "  --detect (default)  Auto-detect OS and run appropriate setup"
    echo "  --help              Show this message"
    echo ""
    exit 1
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)
            # Check if it's Arch Linux
            if [[ -f /etc/os-release ]]; then
                if grep -q "^ID=arch" /etc/os-release 2>/dev/null; then
                    echo "arch"
                    return
                fi
            fi
            echo "unknown"
            ;;
        Darwin*)
            echo "mac"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Setup for Arch Linux
setup_arch() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   Arch Linux Setup${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    if [[ ! -f "$INSTALL_DIR/arch/install.sh" ]]; then
        echo -e "${RED}Error: Arch install script not found!${NC}"
        exit 1
    fi
    
    # Make sure scripts are executable
    chmod +x "$INSTALL_DIR/arch/install.sh"
    chmod +x "$INSTALL_DIR/common/setup.sh"
    
    # Run Arch installer
    "$INSTALL_DIR/arch/install.sh" "$@"
    
    echo ""
    echo -e "${GREEN}✓ Arch Linux setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run common tools setup (optional):"
    echo "     $SCRIPT_DIR/setup.sh --common-only"
    echo ""
}

# Setup for macOS
setup_mac() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   macOS Setup${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    if [[ ! -f "$INSTALL_DIR/mac/install.sh" ]]; then
        echo -e "${RED}Error: macOS install script not found!${NC}"
        exit 1
    fi
    
    # Make sure scripts are executable
    chmod +x "$INSTALL_DIR/mac/install.sh"
    chmod +x "$INSTALL_DIR/common/setup.sh"
    
    # Run macOS installer
    "$INSTALL_DIR/mac/install.sh" "$@"
    
    echo ""
    echo -e "${GREEN}✓ macOS setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run common tools setup (optional):"
    echo "     $SCRIPT_DIR/setup.sh --common-only"
    echo ""
}

# Setup common cross-platform tools
setup_common() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}   Common Tools Setup${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    if [[ ! -f "$INSTALL_DIR/common/setup.sh" ]]; then
        echo -e "${RED}Error: Common setup script not found!${NC}"
        exit 1
    fi
    
    chmod +x "$INSTALL_DIR/common/setup.sh"
    "$INSTALL_DIR/common/setup.sh" "$@"
}

# Main function
main() {
    local option="${1:-detect}"
    
    case "$option" in
        --arch)
            setup_arch "${@:2}"
            ;;
        --mac)
            setup_mac "${@:2}"
            ;;
        --common-only)
            setup_common "${@:2}"
            ;;
        --detect)
            local detected_os=$(detect_os)
            echo -e "${BLUE}Detecting OS...${NC} ${GREEN}$detected_os${NC}"
            echo ""
            
            case "$detected_os" in
                arch)
                    setup_arch "${@:2}"
                    ;;
                mac)
                    setup_mac "${@:2}"
                    ;;
                *)
                    echo -e "${RED}Error: Unable to detect OS!${NC}"
                    echo ""
                    echo "Please specify your OS manually:"
                    echo "  $0 --arch   # For Arch Linux"
                    echo "  $0 --mac    # For macOS"
                    exit 1
                    ;;
            esac
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            echo -e "${RED}Unknown option: $option${NC}"
            echo ""
            show_usage
            ;;
    esac
}

main "$@"
