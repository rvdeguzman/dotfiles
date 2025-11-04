#!/bin/bash

# Test script to verify the setup structure is correct
# Run this before using the setup.sh script to ensure everything is in place

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERRORS=0

echo "================================================"
echo "   Testing Setup Structure"
echo "================================================"
echo ""

# Check main setup script
echo -n "Checking main setup.sh... "
if [[ -f "$SCRIPT_DIR/setup.sh" && -x "$SCRIPT_DIR/setup.sh" ]]; then
    echo "✓"
else
    echo "✗"
    ((ERRORS++))
fi

# Check Arch setup
echo -n "Checking Arch setup... "
if [[ -f "$SCRIPT_DIR/install/arch/install.sh" && \
      -x "$SCRIPT_DIR/install/arch/install.sh" && \
      -f "$SCRIPT_DIR/install/arch/packages.txt" ]]; then
    echo "✓"
else
    echo "✗"
    ((ERRORS++))
fi

# Check macOS setup
echo -n "Checking macOS setup... "
if [[ -f "$SCRIPT_DIR/install/mac/install.sh" && \
      -x "$SCRIPT_DIR/install/mac/install.sh" && \
      -f "$SCRIPT_DIR/install/mac/packages.txt" ]]; then
    echo "✓"
else
    echo "✗"
    ((ERRORS++))
fi

# Check common setup
echo -n "Checking common tools setup... "
if [[ -f "$SCRIPT_DIR/install/common/setup.sh" && \
      -x "$SCRIPT_DIR/install/common/setup.sh" ]]; then
    echo "✓"
else
    echo "✗"
    ((ERRORS++))
fi

# Check documentation
echo -n "Checking documentation... "
if [[ -f "$SCRIPT_DIR/README.md" && \
      -f "$SCRIPT_DIR/SETUP_GUIDE.md" && \
      -f "$SCRIPT_DIR/MIGRATION_GUIDE.md" ]]; then
    echo "✓"
else
    echo "✗"
    ((ERRORS++))
fi

echo ""
echo "================================================"

if [[ $ERRORS -eq 0 ]]; then
    echo "✓ All checks passed!"
    echo ""
    echo "You can now run:"
    echo "  ./setup.sh"
    echo ""
    echo "For more information, see:"
    echo "  - SETUP_GUIDE.md for quick start"
    echo "  - README.md for full documentation"
    echo "  - MIGRATION_GUIDE.md for changes from old setup"
    exit 0
else
    echo "✗ Found $ERRORS issue(s)"
    echo ""
    echo "Please verify:"
    echo "  1. All files are in place"
    echo "  2. Scripts have execute permissions"
    echo "  3. No files were corrupted"
    exit 1
fi
