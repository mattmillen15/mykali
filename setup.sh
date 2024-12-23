#!/bin/sh -e
#
# setup.sh — All-in-one script for a user on Kali (or other distros).
# Usage:
#   1) git clone --depth=1 https://github.com/YOUR_USERNAME/mybash.git
#   2) cd mybash
#   3) chmod +x setup.sh
#   4) ./setup.sh
#
# This will:
#   - Install dependencies (bash, tmux, starship, fzf, zoxide, etc.) using sudo if available
#   - Install Terminus Nerd Font
#   - Link .bashrc, starship.toml, tmux configs from this repo to your home
#   - Set Bash as default shell (requires sudo)
#   - Fix file ownership (if run with sudo)
#   - Encourage you to restart or auto-run bash

###############################################################################
# Colors for echo
###############################################################################
RESET='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

###############################################################################
# Helper Functions
###############################################################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

fix_permissions_for_user() {
    # If script is run with sudo, SUDO_USER is the user who invoked sudo.
    # We want that user to own the dotfiles, not root.
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        echo "${YELLOW}Fixing ownership in /home/$SUDO_USER for user $SUDO_USER...${RESET}"
        sudo chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/"
    fi
}

###############################################################################
# Step 1: Check environment
###############################################################################
echo "${YELLOW}[1/8] Checking environment...${RESET}"

# Identify package manager
PACKAGER=''
for p in nala apt dnf yum pacman zypper emerge xbps-install nix-env; do
    if command_exists "$p"; then
        PACKAGER="$p"
        break
    fi
done
if [ -z "$PACKAGER" ]; then
    echo "${RED}No supported package manager found. Aborting.${RESET}"
    exit 1
fi

# Check if we have sudo or are root
USE_SUDO=''
if [ "$(id -u)" -ne 0 ] && command_exists sudo; then
    # normal user + sudo installed
    USE_SUDO='sudo'
fi

echo "${GREEN}Detected package manager: $PACKAGER${RESET}"
if [ -z "$USE_SUDO" ] && [ "$(id -u)" -ne 0 ]; then
    echo "${YELLOW}Note: We won't be able to install system packages without sudo or root!${RESET}"
    echo "Proceeding, but dependency installation will likely fail unless they're already installed."
fi

###############################################################################
# Step 2: Install dependencies (bash, tmux, etc.) if possible
###############################################################################
echo "${YELLOW}[2/8] Installing core dependencies...${RESET}"

DEPENDENCIES="bash bash-completion tar bat tree multitail fastfetch wget unzip fontconfig tmux dconf-cli"

# Optionally add neovim if missing
if ! command_exists nvim; then
    DEPENDENCIES="$DEPENDENCIES neovim"
fi

case "$PACKAGER" in
    pacman)
        if [ -n "$USE_SUDO" ]; then
            # Pacman-based
            $USE_SUDO pacman -Syu --noconfirm $DEPENDENCIES
        fi
        ;;
    nala|apt)
        if [ -n "$USE_SUDO" ]; then
            $USE_SUDO $PACKAGER update -y
            $USE_SUDO $PACKAGER install -y $DEPENDENCIES
        fi
        ;;
    dnf|yum)
        if [ -n "$USE_SUDO" ]; then
            $USE_SUDO $PACKAGER install -y $DEPENDENCIES
        fi
        ;;
    zypper)
        if [ -n "$USE_SUDO" ]; then
            $USE_SUDO zypper refresh
            $USE_SUDO zypper -n install $DEPENDENCIES
        fi
        ;;
    emerge)
        if [ -n "$USE_SUDO" ]; then
            $USE_SUDO emerge -v app-shells/bash app-shells/bash-completion app-arch/tar app-editors/neovim \
                             sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch \
                             x11-terms/xterm x11-misc/pcmanfm
        fi
        ;;
    xbps-install)
        if [ -n "$USE_SUDO" ]; then
            $USE_SUDO xbps-install -S -y $DEPENDENCIES
        fi
        ;;
    nix-env)
        # If you're using Nix, this might require some special handling, but let's keep it simple
        if [ -n "$USE_SUDO" ]; then
            echo "${RED}nix-env under sudo is tricky. You might want to run as normal user with Nix installed globally.${RESET}"
        fi
        ;;
esac
echo "${GREEN}Core dependencies installation attempt complete.${RESET}"

###############################################################################
# Step 3: Install starship & fzf
###############################################################################
echo "${YELLOW}[3/8] Checking / Installing starship & fzf...${RESET}"

if ! command_exists starship; then
    echo "Installing starship..."
    # We won't use sudo here because starship is typically user-local
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

if ! command_exists fzf; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all
fi

###############################################################################
# Step 4: Install zoxide
###############################################################################
echo "${YELLOW}[4/8] Checking / Installing zoxide...${RESET}"

if ! command_exists zoxide; then
    echo "Installing zoxide..."
    # Typically user local as well
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

###############################################################################
# Step 5: Install Terminus Nerd Font
###############################################################################
echo "${YELLOW}[5/8] Installing Terminus Nerd Font...${RESET}"

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Terminus.zip"
FONT_DIR="$HOME/.local/share/fonts"
if [ -n "$FONT_URL" ]; then
    tmpdir="$(mktemp -d)"
    wget -q -O "$tmpdir/Terminus.zip" "$FONT_URL" || true
    if [ -f "$tmpdir/Terminus.zip" ]; then
        mkdir -p "$FONT_DIR"
        unzip -o "$tmpdir/Terminus.zip" -d "$FONT_DIR" >/dev/null 2>&1 || true
        if command_exists fc-cache; then
            fc-cache -fv
        fi
        # If GNOME's gsettings is present, set the font
        if command_exists gsettings; then
            gsettings set org.gnome.desktop.interface monospace-font-name "Terminus Nerd Font 12" || true
        fi
        # If user uses xterm, set it in ~/.Xresources
        if [ -n "$DISPLAY" ]; then
            if [ ! -f "$HOME/.Xresources" ]; then
                touch "$HOME/.Xresources"
            fi
            if ! grep -q "xterm\*faceName: Terminus Nerd Font" "$HOME/.Xresources"; then
                echo "xterm*faceName: Terminus Nerd Font:pixelsize=14" >> "$HOME/.Xresources"
                xrdb -merge "$HOME/.Xresources" || true
            fi
        fi
        echo "${GREEN}Terminus Nerd Font installed.${RESET}"
    else
        echo "${RED}Failed to download Terminus Nerd Font. Skipping font install.${RESET}"
    fi
    rm -rf "$tmpdir"
fi

###############################################################################
# Step 6: Link config files (bashrc, starship, tmux, etc.)
###############################################################################
echo "${YELLOW}[6/8] Linking config files from repo to home...${RESET}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 6a) .bashrc
if [ -f "$HOME/.bashrc" ]; then
    echo "${YELLOW}Backing up old ~/.bashrc to ~/.bashrc.bak${RESET}"
    mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi
echo "Linking .bashrc from repo to $HOME"
ln -s "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"

# 6b) starship.toml
mkdir -p "$HOME/.config"
if [ -f "$SCRIPT_DIR/starship.toml" ]; then
    echo "Linking starship.toml to ~/.config/"
    ln -sf "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"
fi

# 6c) Tmux config if you have tmux/tmux.conf
if [ -f "$SCRIPT_DIR/tmux/tmux.conf" ]; then
    echo "Copying Tmux config from repo..."
    cp "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
    if [ -f "$SCRIPT_DIR/tmux/tmux.conf.local" ]; then
        cp "$SCRIPT_DIR/tmux/tmux.conf.local" "$HOME/.tmux.conf.local"
    fi
fi

###############################################################################
# Step 7: Make Bash the default shell (if we have sudo)
###############################################################################
echo "${YELLOW}[7/8] Setting bash as default shell (if sudo is available)...${RESET}"

if [ -n "$USE_SUDO" ]; then
    $USE_SUDO chsh -s /bin/bash "$USER"
else
    # If we're root, or no sudo, we can try changing for the current user
    if [ "$(id -u)" -eq 0 ]; then
        # If script is run as root, user might be root. That usually won't help.
        echo "${YELLOW}Running as root user; skipping chsh for a normal user.${RESET}"
    else
        # If there's no sudo, but not root, we can attempt chsh without sudo
        chsh -s /bin/bash "$USER" || true
    fi
fi

###############################################################################
# Step 8: Fix ownership if we used sudo, and done
###############################################################################
echo "${YELLOW}[8/8] Fixing ownership (if needed) and finishing...${RESET}"
fix_permissions_for_user

echo "${GREEN}All done! Please restart your shell or run 'exec bash' to see the changes.${RESET}"
