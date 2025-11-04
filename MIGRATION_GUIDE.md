# Migration Guide

This guide explains what changed from your old setup and how to use the new system.

## What Changed

### Before (Old Structure)
```
dotfiles/
├── install_packages.zsh        # Only for Arch Linux
├── install_scripts.txt         # Generic cross-platform script list
├── packages.txt                # Only for Arch Linux
└── .config/                    # Configuration files
```

### After (New Structure)
```
dotfiles/
├── setup.sh                    # Universal entry point (auto-detects OS)
├── SETUP_GUIDE.md              # Quick reference guide
├── install/
│   ├── arch/
│   │   ├── install.sh          # Arch Linux installer
│   │   └── packages.txt        # Arch Linux packages
│   ├── mac/
│   │   ├── install.sh          # macOS installer
│   │   └── packages.txt        # macOS packages
│   └── common/
│       └── setup.sh            # Cross-platform tools
└── .config/                    # Configuration files (unchanged)
```

## Key Improvements

1. **Platform-specific package lists** - Arch and macOS have completely separate package files
   - Arch uses `pacman`/`paru`/`yay`
   - macOS uses Homebrew with separate handling for CLI packages and casks

2. **OS auto-detection** - No need to manually specify your OS
   - `./setup.sh` automatically detects if you're on Arch or macOS
   - Falls back to manual selection if needed

3. **Flexible window manager support** (Arch)
   - Choose between Hyprland, i3, or both
   - Base packages are shared between both

4. **Better tool organization** (macOS)
   - Base packages: CLI tools installed via `brew install`
   - Casks: GUI applications installed via `brew install --cask`
   - Mac-dev: Xcode and development-specific tools

5. **Cross-platform tool installation**
   - Atuin, Zoxide, Oh My Zsh, and SDKMAN can be installed on any platform
   - Separate script that doesn't interfere with OS-specific setup

## Migration Steps

### 1. Backup Your Current Setup (Optional)
```bash
cd ~/dotfiles
git status  # See what's changed
```

### 2. Update Your Repository
```bash
# Your files have been updated in place
# No action needed if they were synced automatically
```

### 3. Use the New Setup

**On Arch Linux:**
```bash
./setup.sh --arch hyprland    # For Hyprland
# or
./setup.sh --arch i3          # For i3
```

**On macOS:**
```bash
./setup.sh --mac full         # Full installation
```

**For Common Tools (Both Platforms):**
```bash
./setup.sh --common-only all  # Or choose individual tools
```

## Package List Mapping

### Arch Linux

All your original packages are now split into:
- **[base]**: All common packages (what you had before)
- **[hyprland]**: Wayland-specific packages (from your original list)
- **[i3]**: X11 window manager packages (new)

### macOS

New package list organized as:
- **[base]**: CLI tools equivalent to Arch base packages
- **[casks]**: GUI applications
- **[mac-dev]**: macOS development tools

## Customizing Packages

### To add a package

1. **Arch Linux:**
   ```bash
   vim install/arch/packages.txt
   # Add package name under appropriate section [base], [hyprland], or [i3]
   ```

2. **macOS:**
   ```bash
   vim install/mac/packages.txt
   # Add package name under [base] for CLI tools or [casks] for GUI apps
   ```

### To remove a package

Simply delete the line from the appropriate `packages.txt` file.

### To change installation type

Just run the setup script again and choose a different option. It will install missing packages.

## Troubleshooting Migration

### Old scripts don't exist anymore

The old scripts have been replaced by the new system:
- `install_packages.zsh` → `install/arch/install.sh`
- `install_scripts.txt` → `install/common/setup.sh`
- `packages.txt` → `install/arch/packages.txt` or `install/mac/packages.txt`

### My packages aren't being installed

Check:
1. The package name is correct for your platform
2. It's in the right section of `packages.txt`
3. The script ran without errors
4. You have the required prerequisites (paru/yay for Arch, Homebrew for macOS)

### I prefer the old way

You can still manually manage packages:

**Arch:**
```bash
paru -S package-name
# or
yay -S package-name
```

**macOS:**
```bash
brew install package-name        # CLI tools
brew install --cask package-name # GUI apps
```

## Environment Variables (Optional)

If you want to automate the setup without prompts, you can set environment variables before running:

See `install/.env.example` for available options.

## What Didn't Change

- All your `.config/` configuration files remain the same
- Your shell profiles and dotfiles work the same way
- The installation process is backward-compatible

## Old Commands Still Work

For Arch Linux, you can still use the old approach if you want:
```bash
# Direct invocation of platform-specific script
./install/arch/install.sh hyprland
```

## Questions?

See:
- `README.md` - Full documentation
- `SETUP_GUIDE.md` - Quick reference
- `install/arch/install.sh --help`
- `install/mac/install.sh --help`
- `install/common/setup.sh --help`
