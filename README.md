# Dotfiles

Rafael Vincent's dotfiles for macOS and Linux.

## Quick Start

### Auto-detect OS and Run Setup

```bash
./setup.sh
```

This will automatically detect your operating system and run the appropriate setup script.

### Manual OS Selection

```bash
# For Arch Linux
./setup.sh --arch

# For macOS
./setup.sh --mac

# For common cross-platform tools only
./setup.sh --common-only
```

## Directory Structure

```
dotfiles/
├── setup.sh                    # Main setup script (auto-detects OS)
├── install/
│   ├── arch/                   # Arch Linux setup
│   │   ├── install.sh          # Arch package installer
│   │   └── packages.txt        # List of Arch packages
│   ├── mac/                    # macOS setup
│   │   ├── install.sh          # macOS package installer (Homebrew)
│   │   └── packages.txt        # List of macOS packages
│   └── common/                 # Cross-platform setup
│       └── setup.sh            # Common tools installer
├── .config/                    # Application configs
│   ├── alacritty/
│   ├── doom/
│   ├── hypr/
│   ├── kitty/
│   ├── tmux/
│   ├── waybar/
│   ├── zsh/
│   └── ...
└── README.md
```

## Setup Instructions

### Prerequisites

#### Arch Linux
- Ensure you have `pacman` installed
- The script will check for `paru` or `yay` (AUR helper)
  - If not found, you can install paru with:
    ```bash
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru && makepkg -si
    ```

#### macOS
- Ensure you have Xcode Command Line Tools (script will prompt if missing)
- Ensure you have Homebrew installed
  - If not found, install with:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

### Installation Steps

1. **Clone or navigate to this repository**
   ```bash
   cd ~/dotfiles  # or wherever you have this repo
   ```

2. **Run the main setup script**
   ```bash
   ./setup.sh
   ```

3. **Choose your setup type when prompted**
   - For **Arch Linux** with Hyprland: select `hyprland`
   - For **Arch Linux** with i3: select `i3`
   - For **Arch Linux** with both: select `both`
   - For **macOS**: select `base` or `full`

4. **(Optional) Install common cross-platform tools**
   ```bash
   ./setup.sh --common-only
   ```
   This installs:
   - Atuin (shell history)
   - Zoxide (smart cd)
   - Oh My Zsh
   - SDKMAN (Java SDK manager)

## What Gets Installed

### Arch Linux

#### Base Packages
Essential tools that are installed regardless of window manager choice:
- Shell: `zsh`, `tmux`
- Editors: `emacs`, `vim`
- Tools: `git`, `github-cli`, `fzf`, `ripgrep`, `bat`, `eza`, `fd`
- Development: `nodejs`, `go`, `python`, `clang`, `cmake`
- Utilities: `firefox`, `mpv`, `syncthing`, `docker`, `ollama-cuda`
- And many more...

#### Hyprland Packages
Wayland-based desktop environment:
- `hyprland`, `hypridle`, `waybar`, `hyprlock`, `mako`
- Screen recording: `wf-recorder`, `grim`, `slurp`, `grimblast-git`
- Wallpaper: `hyprpaper`
- Clipboard: `wl-clipboard`

#### i3 Packages
X11-based window manager:
- `i3-wm`, `i3status`, `i3lock`
- X11 utilities: `xorg-xrandr`, `xorg-setxkbmap`
- Notification daemon: `dunst`

### macOS

#### Base Packages (via Homebrew)
Cross-platform tools that work on macOS:
- Shell: `zsh`, `tmux`
- Editors: `emacs`, `vim`
- Tools: `git`, `gh`, `fzf`, `ripgrep`, `bat`, `eza`, `fd`
- Development: `node`, `go`, `python@3.11`, `llvm`
- Utilities: `firefox`, `mpv`, `syncthing`, `docker`

#### Casks (GUI Applications)
macOS-specific GUI applications:
- `kitty`, `firefox`, `emacs`, `mpv`, `zathura`, `localsend`, `vesktop`, `docker`

#### Mac-dev Packages
macOS development tools:
- Xcode Command Line Tools (checked/installed automatically)
- `llvm`

## Configuration Files

Application-specific configuration files are organized in `.config/`:

- **Shell**: `.config/zsh/.zshrc` - Zsh configuration
- **Terminal**: `.config/kitty/kitty.conf` - Kitty terminal emulator config
- **Editor**: `.config/doom/` - Doom Emacs configuration
- **WM**: `.config/hypr/` - Hyprland window manager config
- **Bar**: `.config/waybar/` - Waybar status bar config
- **Other**: `.config/tmux/`, `.config/lazygit/`, `.config/yazi/`, etc.

## Customization

### Adding or Removing Packages

Edit the package files in `install/arch/packages.txt` or `install/mac/packages.txt`:

```bash
# Arch Linux
vim install/arch/packages.txt

# macOS
vim install/mac/packages.txt
```

Packages are organized by sections:
- `[base]` - Always installed
- `[i3]` or `[hyprland]` - WM-specific (Arch)
- `[casks]` or `[mac-dev]` - macOS-specific

### Modifying Setup Scripts

Each platform has its own install script:
- `install/arch/install.sh`
- `install/mac/install.sh`
- `install/common/setup.sh`

## Troubleshooting

### Arch Linux

**paru not found:**
```bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
```

### macOS

**Homebrew not in PATH:**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
# Add this to your shell profile (.zshrc or .bash_profile)
```

**Xcode tools not installed:**
The script will automatically prompt to install. If manual installation is needed:
```bash
xcode-select --install
```

## Notes

- Scripts use `set -e` to exit on any error
- All scripts are idempotent where possible (safe to run multiple times)
- Some installations may require user interaction or password entry
- After installation, you may need to:
  1. Reload your shell: `exec zsh`
  2. Install additional configuration (symlink dotfiles to home directory)
  3. Customize theme and other preferences

## License

See LICENSE file for details.
