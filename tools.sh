#!/bin/bash
#
# tools.sh — Install additional tools for Kali
# This script can be updated as needed.

set -e

echo "🔧 Installing additional tools..."

# Install via APT
sudo apt install -y \
    seclists \
    jq

# Install via pip3
#pip3 install --upgrade \
#    pwntools \
#    requests \
#    flask

# Install via pipx
pipx install impacket

# Install via GitHub
mkdir -p "$HOME/tools"

if [ ! -d "$HOME/tools/nmapAutomator" ]; then
    git clone https://github.com/mattmillen15 "$HOME/tools/nmapAutomator"
fi

# Ensure tools in PATH
export PATH="$PATH:$HOME/.local/bin"

echo "✅ Tool installation complete!"
