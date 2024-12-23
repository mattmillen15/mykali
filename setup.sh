#!/bin/bash
#
# setup.sh — Simplified Kali Customization Script
# Repo: https://github.com/mattmillen15/mykali

set -e  # Exit on any error

# Paths
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_HOME="$HOME"
RUN_USER="${SUDO_USER:-$USER}"

# Helper Functions
command_exists() { command -v "$1" >/dev/null 2>&1; }

fix_permissions() {
    echo $'\033[33mFixing ownership for user: '"$RUN_USER"$'\033[0m'
    sudo chown -R "$RUN_USER:$RUN_USER" "$USER_HOME"
}

update_system() {
    echo $'\033[33mUpdating package lists...\033[0m'
    sudo apt update
}

install_dependencies() {
    echo $'\033[33mInstalling core dependencies...\033[0m'
    sudo apt install -y \
        bash bash-completion tar bat tree multitail fastfetch wget unzip fontconfig \
        tmux dconf-cli git curl neovim python3-pip pipx starship zoxide
}

setup_bash() {
    echo $'\033[33mSetting up Bash configuration...\033[0m'
    [ -f "$USER_HOME/.bashrc" ] && mv "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak"
    ln -sf "$REPO_DIR/.bashrc" "$USER_HOME/.bashrc"
    mkdir -p "$USER_HOME/.config"
    ln -sf "$REPO_DIR/starship.toml" "$USER_HOME/.config/starship.toml"
}

setup_tmux() {
    echo $'\033[33mSetting up Tmux configuration...\033[0m'
    ln -sf "$REPO_DIR/tmux/tmux.conf" "$USER_HOME/.tmux.conf"
    [ -f "$REPO_DIR/tmux/tmux.conf.local" ] && ln -sf "$REPO_DIR/tmux/tmux.conf.local" "$USER_HOME/.tmux.conf.local"
}

run_tools_installation() {
    echo $'\033[33mRunning custom tools installation...\033[0m'
    if [ -f "$REPO_DIR/tools.sh" ]; then
        chmod +x "$REPO_DIR/tools.sh"
        "$REPO_DIR/tools.sh"
    else
        echo $'\033[31mtools.sh not found. Skipping tool installation.\033[0m'
    fi
}

set_bash_as_default() {
    echo $'\033[33mSetting Bash as the default shell...\033[0m'
    sudo chsh -s /bin/bash "$RUN_USER"
}

finalize() {
    echo $'\033[33mFinalizing setup...\033[0m'
    fix_permissions
    echo $'\033[32mSetup complete! Switching to Bash now...\033[0m'
    exec bash --login
}

# Main Execution
update_system
install_dependencies
setup_bash
setup_tmux
run_tools_installation
set_bash_as_default
finalize
