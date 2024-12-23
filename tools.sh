#!/bin/bash
#
# tools.sh — Install additional tools for Kali
# This script can be updated as needed.

set -e  # Exit on any error

echo "🔧 Installing additional tools..."

#######################################################
# ENSURE ~/tools DIRECTORY EXISTS
#######################################################

TOOLS_DIR="$HOME/tools"
mkdir -p "$TOOLS_DIR"
echo "📁 Ensured '$TOOLS_DIR' exists."

#######################################################
# INSTALL TOOLS VIA APT
#######################################################

echo "📦 Installing tools via APT..."
sudo apt install -y \
    seclists \
    jq

#######################################################
# INSTALL TOOLS VIA PIPX
#######################################################

echo "🐍 Installing tools via pipx..."
if command -v pipx &> /dev/null; then
    pipx ensurepath
    pipx install impacket
else
    echo "⚠️ pipx is not installed. Skipping pipx tools."
fi

#######################################################
# INSTALL TOOLS VIA GITHUB
#######################################################

echo "🌐 Installing tools from GitHub repositories..."

# Tool: LDDummy
if [ ! -d "$TOOLS_DIR/LDDummy" ]; then
    echo "➡️ Cloning LDDummy..."
    git clone https://github.com/mattmillen15/LDDummy.git "$TOOLS_DIR/LDDummy"
else
    echo "✅ LDDummy already exists in '$TOOLS_DIR'. Skipping."
fi

# Tool: DumpInspector
if [ ! -d "$TOOLS_DIR/DumpInspector" ]; then
    echo "➡️ Cloning DumpInspector..."
    git clone https://github.com/mattmillen15/DumpInspector.git "$TOOLS_DIR/DumpInspector"
else
    echo "✅ DumpInspector already exists in '$TOOLS_DIR'. Skipping."
fi

# Tool: SwiftSecrets
if [ ! -d "$TOOLS_DIR/SwiftSecrets" ]; then
    echo "➡️ Cloning SwiftSecrets..."
    git clone https://github.com/mattmillen15/SwiftSecrets.git "$TOOLS_DIR/SwiftSecrets"
else
    echo "✅ SwiftSecrets already exists in '$TOOLS_DIR'. Skipping."
fi

#######################################################
# ADD ~/tools TO PATH
#######################################################

echo "🛠️ Adding '$TOOLS_DIR' to PATH if not already included..."
if [[ ":$PATH:" != *":$TOOLS_DIR:"* ]]; then
    export PATH="$PATH:$TOOLS_DIR"
    echo "export PATH=\$PATH:$TOOLS_DIR" >> "$HOME/.bashrc"
    echo "✅ '$TOOLS_DIR' added to PATH."
fi

#######################################################
# VERIFY INSTALLATION
#######################################################

echo "🧪 Verifying tool installations..."

# Verify jq
if command -v jq &> /dev/null; then
    echo "✅ jq is installed successfully."
else
    echo "❌ jq installation failed."
fi

# Verify seclists
if [ -d "/usr/share/seclists" ]; then
    echo "✅ SecLists is installed successfully."
else
    echo "❌ SecLists installation failed."
fi

# Verify impacket
if command -v impacket-smbserver &> /dev/null; then
    echo "✅ Impacket is installed successfully."
else
    echo "❌ Impacket installation failed."
fi

# Verify GitHub tools
for TOOL in LDDummy DumpInspector SwiftSecrets; do
    if [ -d "$TOOLS_DIR/$TOOL" ]; then
        echo "✅ $TOOL is installed in '$TOOLS_DIR/$TOOL'."
    else
        echo "❌ $TOOL installation failed."
    fi
done

#######################################################
# CLEANUP AND FINAL MESSAGE
#######################################################

echo "✅ Tool installation complete!"
echo "🔄 Please restart your terminal or run 'exec bash' to apply changes."
