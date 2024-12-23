#!/bin/sh -e
#
# setup.sh — All-in-one script for Kali that installs:
#   1) Dependencies (bash, tmux, zoxide, starship, fzf, etc.)
#   2) Terminus Nerd Font (for nice glyphs/icons)
#   3) Your myBash config (from this forked repo)
#   4) Your ohmytmux config (tmux/tmux.conf + tmux/tmux.conf.local)
#   5) Sets Bash as default shell, auto-starts Bash

###############################################################################
# Colors for echo
###############################################################################
RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

###############################################################################
# Variables
###############################################################################
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"
PACKAGER=""
SUDO_CMD=""
SUGROUP=""
GITPATH=""  # Will point to this cloned repo directory

###############################################################################
# Helper: command_exists
###############################################################################
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# STEP 1: Pre-flight checks and environment setup
###############################################################################
checkEnv() {
    echo "${YELLOW}Checking environment...${RC}"

    # Requirements to run this script
    REQUIREMENTS='curl groups sudo'
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo "${RED}To run me, you need: $REQUIREMENTS${RC}"
            exit 1
        fi
    done

    # Detect package manager
    PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install nix-env'
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo "Using $pgm for package installation."
            break
        fi
    done
    if [ -z "$PACKAGER" ]; then
        echo "${RED}No supported package manager found!${RC}"
        exit 1
    fi

    # Privilege escalation
    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    # Directory where this script (repo) is located
    GITPATH=$(dirname "$(realpath "$0")")
    if [ ! -w "$GITPATH" ]; then
        echo "${RED}Can't write to $GITPATH. Please clone to a writable location.${RC}"
        exit 1
    fi

    # Figure out superuser group
    SUPERUSERGROUP='wheel sudo root'
    for sug in $SUPERUSERGROUP; do
        if groups | grep -q "$sug"; then
            SUGROUP="$sug"
            break
        fi
    done
    if [ -z "$SUGROUP" ]; then
        # fallback if none found, but typically we want at least "sudo"
        SUGROUP="sudo"
    fi
    if ! groups | grep -q "$SUGROUP"; then
        echo "${RED}You need to be in the sudo group (or similar) to run me!${RC}"
        exit 1
    fi

    echo "${GREEN}Environment looks good.${RC}"
}

###############################################################################
# STEP 2: Install dependencies
###############################################################################
installDepend() {
    echo "${YELLOW}Installing dependencies...${RC}"

    # The "core" dependencies. Add what you like here.
    DEPENDENCIES='bash bash-completion tar bat tree multitail fastfetch wget unzip fontconfig tmux xterm dconf-cli'

    # We also want neovim if missing
    if ! command_exists nvim; then
        DEPENDENCIES="$DEPENDENCIES neovim"
    fi

    # Attempt to install with the discovered package manager
    case "$PACKAGER" in
        pacman)
            # Arch-based
            if ! command_exists yay && ! command_exists paru; then
                echo "Installing yay as AUR helper..."
                $SUDO_CMD $PACKAGER --noconfirm -S base-devel
                cd /opt && $SUDO_CMD git clone https://aur.archlinux.org/yay-git.git && $SUDO_CMD chown -R "${USER}:${USER}" ./yay-git
                cd yay-git && makepkg --noconfirm -si
            fi
            if command_exists yay; then
                yay --noconfirm -S $DEPENDENCIES
            elif command_exists paru; then
                paru --noconfirm -S $DEPENDENCIES
            fi
            ;;
        nala|apt)
            $SUDO_CMD $PACKAGER install -y $DEPENDENCIES
            ;;
        dnf|yum)
            $SUDO_CMD $PACKAGER install -y $DEPENDENCIES
            ;;
        zypper)
            $SUDO_CMD zypper refresh
            $SUDO_CMD zypper -n install $DEPENDENCIES
            ;;
        emerge)
            # Gentoo
            $SUDO_CMD emerge -v app-shells/bash app-shells/bash-completion app-arch/tar app-editors/neovim sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch x11-terms/xterm x11-misc/pcmanfm
            ;;
        xbps-install)
            $SUDO_CMD $PACKAGER -y install $DEPENDENCIES
            ;;
        nix-env)
            $SUDO_CMD $PACKAGER -iA nixos.bash nixos.bash-completion nixos.gnutar nixos.neovim nixos.bat nixos.tree nixos.multitail nixos.fastfetch nixos.tmux nixos.xterm
            ;;
    esac

    echo "${GREEN}Dependencies installed.${RC}"
}

###############################################################################
# STEP 3: Install Starship & FZF
###############################################################################
installStarshipAndFzf() {
    echo "${YELLOW}Checking Starship / fzf...${RC}"

    if command_exists starship; then
        echo "Starship already installed."
    else
        echo "Installing Starship..."
        if ! curl -sS https://starship.rs/install.sh | sh -s -- -y; then
            echo "${RED}Starship installation failed!${RC}"
            exit 1
        fi
    fi

    if command_exists fzf; then
        echo "FZF already installed."
    else
        echo "Installing FZF..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all
    fi
}

###############################################################################
# STEP 4: Install zoxide
###############################################################################
installZoxide() {
    echo "${YELLOW}Checking zoxide...${RC}"
    if command_exists zoxide; then
        echo "Zoxide already installed."
        return
    fi
    echo "Installing zoxide..."
    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo "${RED}zoxide installation failed!${RC}"
        exit 1
    fi
}

###############################################################################
# STEP 5: (Optional) Additional dependencies
###############################################################################
install_additional_dependencies() {
    # This function is mostly a placeholder in ChrisTitusTech’s version
    # You could install alternative versions of neovim here, etc.
    return 0
}

###############################################################################
# STEP 6: Install Terminus Nerd Font (instead of Meslo)
###############################################################################
installTerminusNerdFont() {
    echo "${YELLOW}Installing Terminus Nerd Font...${RC}"
    FONT_NAME="Terminus Nerd Font"
    # If we want to be thorough, we could check if it’s installed. But let’s just proceed.
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Terminus.zip"
    FONT_DIR="$HOME/.local/share/fonts"
    TEMP_DIR=$(mktemp -d)

    if wget -q --spider "$FONT_URL"; then
        wget -q --show-progress "$FONT_URL" -O "$TEMP_DIR/Terminus.zip"
        unzip -o "$TEMP_DIR/Terminus.zip" -d "$FONT_DIR"
        fc-cache -fv
        rm -rf "$TEMP_DIR"
        echo "${GREEN}'$FONT_NAME' installed successfully.${RC}"

        # Try to set it as GNOME’s default monospace if gsettings is available
        if command_exists gsettings; then
            gsettings set org.gnome.desktop.interface monospace-font-name "Terminus Nerd Font 12" || true
            echo "[OK] Set 'Terminus Nerd Font 12' as GNOME monospace font."
        fi

        # If user runs pure xterm, we set it in ~/.Xresources
        if [ -n "$DISPLAY" ]; then
            XRES="$HOME/.Xresources"
            if ! grep -q "xterm\*faceName: Terminus Nerd Font" "$XRES" 2>/dev/null; then
                echo "xterm*faceName: Terminus Nerd Font:pixelsize=14" >> "$XRES"
                xrdb -merge "$XRES" || true
                echo "[OK] Added xterm config in ~/.Xresources"
            fi
        fi
    else
        echo "${RED}Terminus Nerd Font URL not accessible. Skipping.${RC}"
    fi
}

###############################################################################
# STEP 7: Create fastfetch config symlink (if needed)
###############################################################################
create_fastfetch_config() {
    if [ ! -d "$HOME/.config/fastfetch" ]; then
        mkdir -p "$HOME/.config/fastfetch"
    fi
    # Remove existing config.jsonc link/file if present
    if [ -e "$HOME/.config/fastfetch/config.jsonc" ]; then
        rm -f "$HOME/.config/fastfetch/config.jsonc"
    fi

    # The repo includes config.jsonc, so link it
    if [ -f "$GITPATH/config.jsonc" ]; then
        ln -svf "$GITPATH/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    fi
}

###############################################################################
# STEP 8: Link or replace user’s Bash configs
###############################################################################
linkConfig() {
    OLD_BASHRC="$HOME/.bashrc"
    if [ -e "$OLD_BASHRC" ]; then
        echo "${YELLOW}Moving old bash config file to ~/.bashrc.bak${RC}"
        mv "$OLD_BASHRC" "$HOME/.bashrc.bak"
    fi

    echo "${YELLOW}Linking new bash config file...${RC}"
    ln -svf "$GITPATH/.bashrc" "$HOME/.bashrc"

    # starship.toml?
    if [ ! -d "$HOME/.config" ]; then
        mkdir -p "$HOME/.config"
    fi
    if [ -f "$GITPATH/starship.toml" ]; then
        ln -svf "$GITPATH/starship.toml" "$HOME/.config/starship.toml"
    fi

    echo "${GREEN}.bashrc and starship.toml linked.${RC}"
}

###############################################################################
# STEP 9: OhMyTmux config from tmux/ into home directory
###############################################################################
installTmuxConfig() {
    # If you copied ohmytmux config into tmux/tmux.conf and tmux/tmux.conf.local
    # in your repo, let’s install them:
    TMUX_DIR="$GITPATH/tmux"
    if [ -f "$TMUX_DIR/tmux.conf" ]; then
        echo "${YELLOW}Copying ohmytmux config...${RC}"
        cp -f "$TMUX_DIR/tmux.conf" "$HOME/.tmux.conf"
        if [ -f "$TMUX_DIR/tmux.conf.local" ]; then
            cp -f "$TMUX_DIR/tmux.conf.local" "$HOME/.tmux.conf.local"
        fi
        echo "${GREEN}Tmux config installed!${RC}"
    else
        echo "${YELLOW}No custom tmux config found in $TMUX_DIR. Skipping.${RC}"
    fi
}

###############################################################################
# STEP 10: Make Bash default shell and auto-start
###############################################################################
makeBashDefault() {
    echo "${YELLOW}Setting bash as default shell...${RC}"
    # This will affect the current user only
    chsh -s /bin/bash "${USER}"
    echo "${GREEN}Bash is now default. (You may need to logout/login for it to fully apply.)${RC}"
}

###############################################################################
# Main Execution Flow
###############################################################################
checkEnv
installDepend
installStarshipAndFzf
installZoxide
install_additional_dependencies
installTerminusNerdFont
create_fastfetch_config
linkConfig
installTmuxConfig
makeBashDefault

echo ""
echo "${GREEN}All done! Restarting into bash...${RC}"
exec bash
