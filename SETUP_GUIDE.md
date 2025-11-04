# Setup Guide

Quick reference for setting up your system with this dotfiles repository.

## TL;DR

```bash
cd ~/dotfiles
./setup.sh
```

That's it! The script will auto-detect your OS and run the appropriate setup.

## Detailed Options

### For Arch Linux

```bash
# Interactive menu (recommended)
./setup.sh --arch

# Or directly specify installation type
./setup.sh --arch hyprland    # Hyprland + base packages
./setup.sh --arch i3          # i3 + base packages
./setup.sh --arch both        # All packages (base + hyprland + i3)
```

### For macOS

```bash
# Interactive menu (recommended)
./setup.sh --mac

# Or directly specify installation type
./setup.sh --mac base         # Base packages only
./setup.sh --mac full         # All packages (base + casks + mac-dev)
```

### Common Tools (Both Platforms)

```bash
# Interactive menu (recommended)
./setup.sh --common-only

# Or directly specify tool
./setup.sh --common-only all      # All common tools
./setup.sh --common-only atuin    # Just Atuin
./setup.sh --common-only zoxide   # Just Zoxide
./setup.sh --common-only ohmyzsh  # Just Oh My Zsh
./setup.sh --common-only sdkman   # Just SDKMAN
```

## What's Installed

### Arch Linux

**Base** (always installed):
- Development tools: git, nodejs, go, python, clang, cmake
- Utilities: fzf, ripgrep, bat, fd, eza, tmux, zsh
- Applications: firefox, emacs, kitty, lazygit, mpv
- System: docker, syncthing, ollama-cuda

**Hyprland** (Wayland compositor):
- `hyprland`, `hypridle`, `waybar`, `hyprlock`
- Screen recording & screenshots: `grim`, `slurp`, `grimblast-git`

**i3** (X11 window manager):
- `i3-wm`, `i3status`, `i3lock`, and X11 utilities

### macOS

**Base** (always installed):
- Development tools: git, node, go, python, llvm, cmake
- Utilities: fzf, ripgrep, bat, fd, eza, tmux, zsh
- Applications: firefox, emacs, mpv

**Casks** (GUI applications):
- kitty, firefox, emacs, mpv, docker, localsend, vesktop

**Mac-dev** (development tools):
- Xcode Command Line Tools (auto-checked)
- llvm

## Prerequisites

### Arch Linux

Ensure you have `paru` or `yay` installed:

```bash
# Install paru
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
```

### macOS

Ensure you have:
1. **Xcode Command Line Tools** - Script will install if missing
2. **Homebrew** - Script will prompt if missing
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

## Post-Installation

After running the setup, you might want to:

1. **Link dotfiles to home directory**
   - Symlink `.config` directories to `~/.config/`
   - Symlink shell configs to `~/`

2. **Reload your shell**
   ```bash
   exec zsh
   ```

3. **Initialize shell extensions** (if not already done)
   ```bash
   # For Zoxide (already added by common setup)
   eval "$(zoxide init zsh)"
   
   # For SDKMAN (if installed)
   source "$HOME/.sdkman/bin/sdkman-init.sh"
   ```

4. **Customize your setup**
   - Edit `.config/` files for your preferred tools
   - Install additional packages as needed

## Updating Packages

To add or remove packages, edit the appropriate file:

```bash
# Arch Linux
vim install/arch/packages.txt

# macOS
vim install/mac/packages.txt
```

Then run the setup script again.

## Troubleshooting

### Script won't run

Make sure the main script is executable:
```bash
chmod +x ~/dotfiles/setup.sh
```

### Arch: paru not found

Install paru first:
```bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
```

### macOS: Homebrew not in PATH

Add Homebrew to your shell profile:
```bash
# Add to ~/.zshrc or ~/.bash_profile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then reload:
```bash
exec zsh
```

### macOS: Xcode tools installation fails

Try installing manually:
```bash
xcode-select --install
```

## File Structure

```
dotfiles/
├── setup.sh                    # Main entry point
├── install/
│   ├── arch/
│   │   ├── install.sh          # Arch installer
│   │   └── packages.txt        # Arch packages
│   ├── mac/
│   │   ├── install.sh          # macOS installer
│   │   └── packages.txt        # macOS packages
│   └── common/
│       └── setup.sh            # Common tools
├── .config/                    # Application configs
│   ├── zsh/
│   ├── tmux/
│   ├── kitty/
│   ├── hypr/
│   ├── doom/
│   └── ...
└── README.md
```

## Advanced Usage

### Install only base packages

**Arch:**
```bash
./setup.sh --arch
# Choose "base" (not shown in menu, but edit script)
```

**macOS:**
```bash
./setup.sh --mac base
```

### Install without prompts

```bash
# Arch with hyprland
./setup.sh --arch hyprland

# macOS with all packages
./setup.sh --mac full

# Common tools
./setup.sh --common-only all
```

## Support

For issues with this setup:
1. Check the README.md for more detailed information
2. Verify prerequisites are installed
3. Make sure you're running the correct script for your OS
4. Check the script output for specific error messages
