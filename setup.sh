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
# INSTALL DEPENDENCIES
#######################################################
echo -e "${YELLOW}📦 Installing Required Tools and Dependencies...${RESET}"
sudo apt install -y \
    starship \
    zoxide \
    trash-cli \
    seclists \
    jq \
    bat \
    tree \
    fzf \
    fastfetch \
    neovim

#######################################################
# CONFIGURE TOOLS
#######################################################

# Ensure ~/tools directory exists
echo -e "${YELLOW}🛠 Ensuring ~/tools directory exists...${RESET}"
mkdir -p ~/tools

# Clone custom tools from GitHub if they don't exist
declare -A GITHUB_TOOLS=(
    ["LDDummy"]="https://github.com/mattmillen15/LDDummy"
    ["DumpInspector"]="https://github.com/mattmillen15/DumpInspector"
    ["SwiftSecrets"]="https://github.com/mattmillen15/SwiftSecrets"
)

for tool in "${!GITHUB_TOOLS[@]}"; do
    if [ ! -d "$HOME/tools/$tool" ]; then
        echo -e "${YELLOW}⬇️  Cloning $tool...${RESET}"
        git clone "${GITHUB_TOOLS[$tool]}" "$HOME/tools/$tool"
    else
        echo -e "${GREEN}✅ $tool already exists, skipping...${RESET}"
    fi
done

# Ensure tools in PATH
if [[ ":$PATH:" != *":$HOME/tools:"* ]]; then
    echo -e "${YELLOW}🛠 Adding ~/tools to PATH...${RESET}"
    echo 'export PATH="$HOME/tools:$PATH"' >> ~/.bashrc
fi

#######################################################
# FASTFETCH CONFIGURATION
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
