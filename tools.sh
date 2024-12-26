#!/bin/bash

# Colors for messages
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

echo -e "${YELLOW}🔧 Starting Tool Installation...${RESET}"

#######################################################
# ENSURE ~/TOOLS DIRECTORY EXISTS
#######################################################
echo -e "${YELLOW}🛠 Ensuring ~/tools directory exists...${RESET}"
mkdir -p ~/tools

#######################################################
# INSTALL TOOLS VIA APT
#######################################################
echo -e "${YELLOW}📦 Installing Tools via APT...${RESET}"

# List of APT tools (Add or remove as needed, one per line)
APT_TOOLS=(
    seclists
)

# Install each APT tool
for tool in "${APT_TOOLS[@]}"; do
    if ! dpkg -l | grep -q "^ii  $tool"; then
        echo -e "${YELLOW}➡️ Installing $tool...${RESET}"
        sudo apt install -y "$tool"
    else
        echo -e "${GREEN}✅ $tool is already installed.${RESET}"
    fi
done

#######################################################
# INSTALL TOOLS VIA PIP3
#######################################################
echo -e "${YELLOW}🐍 Installing Tools via pip3...${RESET}"

# List of pip3 tools (Add or remove as needed, one per line)
PIP3_TOOLS=(
    requests
    flask
)

# Install each pip3 tool
for tool in "${PIP3_TOOLS[@]}"; do
    if ! pip3 show "$tool" &> /dev/null; then
        echo -e "${YELLOW}➡️ Installing $tool...${RESET}"
        pip3 install --upgrade "$tool"
    else
        echo -e "${GREEN}✅ $tool is already installed.${RESET}"
    fi
done

#######################################################
# INSTALL TOOLS VIA PIPX
#######################################################
echo -e "${YELLOW}📦 Installing Tools via pipx...${RESET}"

# List of pipx tools (Add or remove as needed, one per line)
PIPX_TOOLS=(
    impacket
)

# Install each pipx tool
if command -v pipx &> /dev/null; then
    for tool in "${PIPX_TOOLS[@]}"; do
        if ! pipx list | grep -q "$tool"; then
            echo -e "${YELLOW}➡️ Installing $tool...${RESET}"
            pipx install "$tool"
        else
            echo -e "${GREEN}✅ $tool is already installed.${RESET}"
        fi
    done
else
    echo -e "${RED}❌ pipx is not installed. Run 'sudo apt install pipx'.${RESET}"
fi

#######################################################
# INSTALL TOOLS FROM GITHUB
#######################################################
echo -e "${YELLOW}⬇️ Installing Tools from GitHub...${RESET}"

# List of GitHub repositories (Add or remove as needed, one per line)
GITHUB_TOOLS=(
    "https://github.com/tmux-plugins/tpm"
    "https://github.com/mattmillen15/LDDummy"
    "https://github.com/mattmillen15/DumpInspector"
    "https://github.com/mattmillen15/SwiftSecrets"
)

# Clone each GitHub repository
for repo in "${GITHUB_TOOLS[@]}"; do
    repo_name=$(basename "$repo")
    if [ ! -d "$HOME/tools/$repo_name" ]; then
        echo -e "${YELLOW}➡️ Cloning $repo_name...${RESET}"
        git clone "$repo" "$HOME/tools/$repo_name"
    else
        echo -e "${GREEN}✅ $repo_name already exists, skipping...${RESET}"
    fi
done

#######################################################
# UPDATE PATH
#######################################################
echo -e "${YELLOW}🛠 Ensuring ~/tools is in PATH...${RESET}"
if [[ ":$PATH:" != *":$HOME/tools:"* ]]; then
    echo 'export PATH="$HOME/tools:$PATH"' >> ~/.bashrc
fi

#######################################################
# VERIFICATION
#######################################################
echo -e "${YELLOW}✅ Verifying Installed Tools...${RESET}"
declare -a VERIFY_TOOLS=("${APT_TOOLS[@]}" "${PIP3_TOOLS[@]}" "${PIPX_TOOLS[@]}")

for tool in "${VERIFY_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null || [ -d "$HOME/tools/$tool" ]; then
        echo -e "${GREEN}✅ $tool is installed.${RESET}"
    else
        echo -e "${RED}❌ $tool is missing.${RESET}"
    fi
done

echo -e "${GREEN}✅ Tools Installation Complete!${RESET}"
