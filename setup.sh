#!/bin/bash
#
# setup.sh — Simplified Kali Customization Script
# Repo: https://github.com/mattmillen15/mykali

set -e  # Exit on any error

# Colors
RESET='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

# Paths
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_HOME="$HOME"
RUN_USER="${SUDO_USER:-$USER}"

# Helper Functions
command_exists() { command -v "$1" >/dev/null 2>&1; }

fix_permissions() {
    echo "${YELLOW}Fixing ownership for user: $RUN_USER${RESET}"
    sudo chown -R "$RUN_USER:$RUN_USER" "$USER_HOME"
}

update_system() {
    echo "${YELLOW}Updating package lists...${RESET}"
    sudo apt update
}

install_dependencies() {
    echo "${YELLOW}Installing core dependencies...${RESET}"
    sudo apt install -y \
        bash bash-completion tar bat tree multitail fastfetch wget unzip fontconfig \
        tmux dconf-cli git curl neovim python3-pip pipx
}

install_starship() {
    echo "${YELLOW}Installing Starship...${RESET}"
    if ! command_exists starship; then
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    else
        echo "${GREEN}Starship is already installed.${RESET}"
    fi
}

install_zoxide() {
    echo "${YELLOW}Installing Zoxide...${RESET}"
    if ! command_exists zoxide; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
        echo "${GREEN}Zoxide is already installed.${RESET}"
    fi
}

install_fzf() {
    echo "${YELLOW}Installing fzf...${RESET}"
    if ! command_exists fzf; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all
    else
        echo "${GREEN}fzf is already installed.${RESET}"
    fi
}

setup_bash() {
    echo "${YELLOW}Setting up Bash configuration...${RESET}"
    [ -f "$USER_HOME/.bashrc" ] && mv "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak"
    ln -sf "$REPO_DIR/.bashrc" "$USER_HOME/.bashrc"
    mkdir -p "$USER_HOME/.config"
    ln -sf "$REPO_DIR/starship.toml" "$USER_HOME/.config/starship.toml"
}

setup_tmux() {
    echo "${YELLOW}Setting up Tmux configuration...${RESET}"
    ln -sf "$REPO_DIR/tmux/tmux.conf" "$USER_HOME/.tmux.conf"
    [ -f "$REPO_DIR/tmux/tmux.conf.local" ] && ln -sf "$REPO_DIR/tmux/tmux.conf.local" "$USER_HOME/.tmux.conf.local"
}

run_tools_installation() {
    echo "${YELLOW}Running custom tools installation...${RESET}"
    if [ -f "$REPO_DIR/tools.sh" ]; then
        chmod +x "$REPO_DIR/tools.sh"
        "$REPO_DIR/tools.sh"
    else
        echo "${RED}tools.sh not found. Skipping tool installation.${RESET}"
    fi
}

set_bash_as_default() {
    echo "${YELLOW}Setting Bash as the default shell...${RESET}"
    sudo chsh -s /bin/bash "$RUN_USER"
}

finalize() {
    echo "${YELLOW}Finalizing setup...${RESET}"
    fix_permissions
    echo "${GREEN}Setup complete! Restart your shell or run 'exec bash' to apply changes.${RESET}"
}

# Main Execution
update_system
install_dependencies
install_starship
install_zoxide
install_fzf
setup_bash
setup_tmux
run_tools_installation
set_bash_as_default
finalize
