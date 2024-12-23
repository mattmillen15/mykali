#!/bin/bash
#
# tools.sh — Install additional tools for Kali
# This script can be updated as needed.

set -e  # Exit on any error

TOOLS_DIR="$HOME/tools"
mkdir -p "$TOOLS_DIR"
echo $'\033[33m📁 Ensured tools directory exists at: '"$TOOLS_DIR"$'\033[0m'

#######################################################
# INSTALL TOOLS VIA APT
#######################################################

echo $'\033[33m📦 Installing tools via APT...\033[0m'
sudo apt install -y \
    seclists \
    jq

#######################################################
# INSTALL TOOLS VIA PIPX
#######################################################

echo $'\033[33m🐍 Installing tools via pipx...\033[0m'
if command -v pipx &> /dev/null; then
    pipx ensurepath
    pipx install impacket
else
    echo $'\033[31m⚠️ pipx is not installed. Skipping pipx tools.\033[0m'
fi

#######################################################
# INSTALL TOOLS VIA GITHUB
#######################################################

echo $'\033[33m🌐 Installing tools from GitHub repositories...\033[0m'

# Tool: LDDummy
if [ ! -d "$TOOLS_DIR/LDDummy" ]; then
    echo $'\033[33m➡️ Cloning LDDummy...\033[0m'
    git clone https://github.com/mattmillen15/LDDummy.git "$TOOLS_DIR/LDDummy"
else
    echo $'\033[32m✅ LDDummy already exists. Skipping.\033[0m'
fi

# Tool: DumpInspector
if [ ! -d "$TOOLS_DIR/DumpInspector" ]; then
    echo $'\033[33m➡️ Cloning DumpInspector...\033[0m'
    git clone https://github.com/mattmillen15/DumpInspector.git "$TOOLS_DIR/DumpInspector"
else
    echo $'\033[32m✅ DumpInspector already exists. Skipping.\033[0m'
fi

# Tool: SwiftSecrets
if [ ! -d "$TOOLS_DIR/SwiftSecrets" ]; then
    echo $'\033[33m➡️ Cloning SwiftSecrets...\033[0m'
    git clone https://github.com/mattmillen15/SwiftSecrets.git "$TOOLS_DIR/SwiftSecrets"
else
    echo $'\033[32m✅ SwiftSecrets already exists. Skipping.\033[0m'
fi

#######################################################
# ADD ~/tools TO PATH
#######################################################

if [[ ":$PATH:" != *":$TOOLS_DIR:"* ]]; then
    echo $'\033[33m🛠️ Adding tools directory to PATH...\033[0m'
    export PATH="$PATH:$TOOLS_DIR"
    echo "export PATH=\$PATH:$TOOLS_DIR" >> "$HOME/.bashrc"
    echo $'\033[32m✅ Tools directory added to PATH.\033[0m'
fi

#######################################################
# VERIFY INSTALLATION
#######################################################

echo $'\033[33m🧪 Verifying tool installations...\033[0m'

# Verify jq
command -v jq &> /dev/null && echo $'\033[32m✅ jq is installed successfully.\033[0m'

# Verify seclists
[ -d "/usr/share/seclists" ] && echo $'\033[32m✅ SecLists is installed successfully.\033[0m'

# Verify impacket
command -v impacket-smbserver &> /dev/null && echo $'\033[32m✅ Impacket is installed successfully.\033[0m'

# Verify GitHub tools
for TOOL in LDDummy DumpInspector SwiftSecrets; do
    if [ -d "$TOOLS_DIR/$TOOL" ]; then
        echo $'\033[32m✅ '"$TOOL"' is installed in '"$TOOLS_DIR/$TOOL"$'\033[0m'
    else
        echo $'\033[31m❌ '"$TOOL"' installation failed.\033[0m'
    fi
done

echo $'\033[32m✅ Tool installation complete!\033[0m'
echo $'\033[33m🔄 Please restart your terminal or run '\''exec bash'\'' to apply changes.\033[0m'
