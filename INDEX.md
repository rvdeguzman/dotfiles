# Dotfiles Setup - Complete Index

**Last Updated:** November 4, 2025

A comprehensive guide to your refactored dotfiles setup system.

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Files Overview](#files-overview)
3. [Documentation Map](#documentation-map)
4. [Setup Options](#setup-options)
5. [What Gets Installed](#what-gets-installed)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### For the Impatient
```bash
cd ~/dotfiles
./setup.sh
```

### For the Cautious
```bash
cd ~/dotfiles
./test-setup.sh    # Verify everything is ready
./setup.sh --help  # See all options
```

---

## 📁 Files Overview

### Setup Scripts

| File | Purpose | Size |
|------|---------|------|
| **setup.sh** | Main entry point, auto-detects OS | 4.4 KB |
| **test-setup.sh** | Verification script | 1.5 KB |

### Arch Linux

| File | Purpose |
|------|---------|
| **install/arch/install.sh** | Arch package installer |
| **install/arch/packages.txt** | Arch packages list |

### macOS

| File | Purpose |
|------|---------|
| **install/mac/install.sh** | macOS/Homebrew installer |
| **install/mac/packages.txt** | macOS packages list |

### Cross-Platform

| File | Purpose |
|------|---------|
| **install/common/setup.sh** | Common tools installer |
| **install/.env.example** | Optional configuration |

### Documentation

| File | Read Time | Purpose |
|------|-----------|---------|
| **SETUP_GUIDE.md** | 5 min | Quick reference & TL;DR |
| **README.md** | 10 min | Complete documentation |
| **MIGRATION_GUIDE.md** | 10 min | Changes from old setup |
| **REFACTOR_SUMMARY.md** | 10 min | Technical details |
| **INDEX.md** | 5 min | This file |

---

## 🗺️ Documentation Map

### I want to...

**Get started immediately**
→ Read: [SETUP_GUIDE.md](SETUP_GUIDE.md)
```bash
./setup.sh
```

**Understand the system**
→ Read: [README.md](README.md)

**Upgrade from old setup**
→ Read: [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)

**Know technical details**
→ Read: [REFACTOR_SUMMARY.md](REFACTOR_SUMMARY.md)

**Add/remove packages**
→ Edit: `install/arch/packages.txt` or `install/mac/packages.txt`

**Customize my setup**
→ Reference: `install/.env.example`

**Verify everything works**
→ Run: `./test-setup.sh`

---

## 🎯 Setup Options

### Basic Setup (Auto-detect)
```bash
./setup.sh
```
Automatically detects Arch Linux or macOS and runs appropriate setup.

### Arch Linux Setups

| Command | What | Best For |
|---------|------|----------|
| `./setup.sh --arch` | Interactive menu | Unsure which to choose |
| `./setup.sh --arch hyprland` | Base + Hyprland | Modern Wayland |
| `./setup.sh --arch i3` | Base + i3 | X11 window manager |
| `./setup.sh --arch both` | All packages | Want everything |

### macOS Setups

| Command | What | Best For |
|---------|------|----------|
| `./setup.sh --mac` | Interactive menu | Unsure |
| `./setup.sh --mac base` | Base packages only | Minimal setup |
| `./setup.sh --mac full` | Base + Casks + Dev tools | Complete setup |

### Common Tools (Both Platforms)

```bash
./setup.sh --common-only      # Interactive menu
./setup.sh --common-only all  # Install all tools
./setup.sh --common-only atuin    # Just Atuin
./setup.sh --common-only zoxide   # Just Zoxide
./setup.sh --common-only ohmyzsh  # Just Oh My Zsh
./setup.sh --common-only sdkman   # Just SDKMAN
```

### Help & Information

```bash
./setup.sh --help             # Show setup.sh options
./install/arch/install.sh --help    # Arch installer options
./install/mac/install.sh --help     # macOS installer options
./install/common/setup.sh --help    # Common tools options
./test-setup.sh               # Verify installation
```

---

## 📦 What Gets Installed

### Arch Linux

**Base Packages** (always installed)
```
Development: git, nodejs, go, python, clang, cmake
Tools: fzf, ripgrep, bat, fd, eza, tmux, zsh
Applications: emacs, firefox, kitty, mpv, lazygit
System: docker, syncthing, ollama-cuda
...and 30+ more
```

**Hyprland** (Wayland desktop)
```
hyprland, hypridle, waybar, hyprlock, mako
wf-recorder, grim, slurp, grimblast-git, hyprpaper
```

**i3** (X11 window manager)
```
i3-wm, i3status, i3lock
X11 utilities: xorg-xrandr, xorg-setxkbmap
```

### macOS

**Base Packages** (Homebrew CLI tools)
```
Development: node, go, python, llvm, cmake, git
Tools: fzf, ripgrep, bat, fd, eza, tmux, zsh
Applications: emacs, firefox, mpv
...and more
```

**Casks** (GUI applications)
```
kitty, firefox, emacs, mpv, zathura
docker, localsend, vesktop
```

**Mac-dev** (Development tools)
```
Xcode Command Line Tools (auto-checked)
llvm
```

### Common Tools (Both Platforms)

- **Atuin** - Shell history management
- **Zoxide** - Smart cd command
- **Oh My Zsh** - Shell framework
- **SDKMAN** - Java SDK manager

---

## 🔧 Troubleshooting

### Scripts Won't Run
```bash
chmod +x setup.sh test-setup.sh install/*/install.sh install/common/setup.sh
```

### Test Fails
```bash
./test-setup.sh
# Check output for specific errors
```

### Arch: paru Not Found
```bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
```

### macOS: Homebrew Not Found
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### macOS: PATH Issues
```bash
# Add to ~/.zshrc:
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## 📊 System Requirements

### Arch Linux
- Base installation
- sudo privileges
- paru or yay installed (script will check)

### macOS
- macOS 10.14+
- Xcode Command Line Tools (script will install if needed)
- Homebrew (script will check and provide instructions)

---

## 🔄 Workflow

### First Time Setup
1. Run `./test-setup.sh` to verify
2. Read `SETUP_GUIDE.md` for quick reference
3. Run `./setup.sh` and follow prompts
4. (Optional) Install common tools with `./setup.sh --common-only`

### Adding Packages
1. Edit `install/arch/packages.txt` or `install/mac/packages.txt`
2. Run `./setup.sh` again with same options
3. New packages will be installed

### Updating Everything
1. Update package files as needed
2. Run `./setup.sh` again
3. Choose same or different options

---

## 📚 Additional Resources

### In This Repository
- `.config/` - Application configurations
- `wallpapers/` - Wallpaper images
- `LICENSE` - License information

### Online Documentation
- [Arch Wiki](https://wiki.archlinux.org/) - Arch Linux documentation
- [Homebrew Docs](https://docs.brew.sh/) - Homebrew documentation
- [Hyprland Wiki](https://wiki.hyprland.org/) - Hyprland documentation
- [i3 Manual](https://i3wm.org/docs/userguide.html) - i3 window manager guide

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Shell is set to `zsh`
- [ ] Git is installed and configured
- [ ] Your terminal emulator is working (Kitty/Alacritty)
- [ ] Editor is available (Emacs)
- [ ] Symlink dotfiles to home directory
- [ ] Reload shell: `exec zsh`

---

## 🎓 Learning Resources

### Understanding the Setup
1. Start with `SETUP_GUIDE.md` - get it working
2. Read `README.md` - understand what's happening
3. Check `MIGRATION_GUIDE.md` - see what changed
4. Review `REFACTOR_SUMMARY.md` - dive into details

### Modifying the Setup
1. Look at package files: `install/arch/packages.txt`
2. Read script comments: `install/arch/install.sh`
3. Check help: `./install/arch/install.sh --help`

---

## 📞 Need Help?

### Quick Reference
```bash
./setup.sh --help                 # Setup script options
./test-setup.sh                   # Verify system
cat SETUP_GUIDE.md               # Quick start
```

### Full Documentation
```bash
cat README.md                     # Complete docs
cat MIGRATION_GUIDE.md            # If upgrading
cat REFACTOR_SUMMARY.md           # Technical details
```

### Run Individual Scripts
```bash
./install/arch/install.sh --help
./install/mac/install.sh --help
./install/common/setup.sh --help
```

---

## 🎉 Summary

Your dotfiles setup has been completely refactored with:

✓ **Multi-platform support** - Arch Linux & macOS  
✓ **Easy installation** - One command: `./setup.sh`  
✓ **Comprehensive docs** - 4 guides + inline help  
✓ **Modular design** - Easy to customize  
✓ **Quality assurance** - Verification script included  
✓ **Backward compatible** - Your configs unchanged  

Get started now:
```bash
cd ~/dotfiles
./setup.sh
```

Enjoy! 🚀

---

**Created:** November 4, 2025  
**Refactored:** Complete system reorganization  
**Status:** Ready to use ✓
