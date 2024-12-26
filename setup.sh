#!/bin/bash

# Colors for messages
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

echo -e "${YELLOW}🔧 Starting Kali Custom Environment Setup...${RESET}"

#######################################################
# UPDATE SYSTEM
#######################################################
echo -e "${YELLOW}🔄 Updating System Packages...${RESET}"
sudo apt update

#######################################################
# INSTALL CORE DEPENDENCIES
#######################################################
echo -e "${YELLOW}📦 Installing Core Dependencies...${RESET}"
sudo apt install -y \
    starship \
    zoxide \
    trash-cli \
    fastfetch \
    neovim \
    jq \
    tree \
    bat \
    fzf

git clone https://github.com/tmux-plugins/tpm.git ~/mykali/tmux/plugins/.
git clone https://github.com/catppuccin/tmux.git ~/mykali/tmux/plugins/catppuccin/tmux

#######################################################
# TOOLS INSTALLATION (via tools.sh)
#######################################################
echo -e "${YELLOW}🛠 Running Tools Installation Script...${RESET}"
chmod +x ./tools.sh
./tools.sh

#######################################################
# CONFIGURE FASTFETCH
#######################################################
echo -e "${YELLOW}🎨 Configuring Fastfetch...${RESET}"
mkdir -p ~/.config/fastfetch
ln -sf ~/mykali/config.jsonc ~/.config/fastfetch/config.jsonc

#######################################################
# LINK CONFIG FILES
#######################################################
echo -e "${YELLOW}🔗 Linking Configuration Files...${RESET}"
ln -sf ~/mykali/starship.toml ~/.config/starship.toml
ln -sf ~/mykali/.bashrc ~/.bashrc

#######################################################
# FINALIZE SETUP
#######################################################
echo -e "${YELLOW}⚙️ Finalizing setup...${RESET}"
CURRENT_USER=$(whoami)
sudo chsh -s /bin/bash "$CURRENT_USER"
sudo chown -R "$CURRENT_USER":"$CURRENT_USER" "$HOME"

echo -e "${GREEN}✅ Setup complete! Restarting shell...${RESET}"
exec bash --login
