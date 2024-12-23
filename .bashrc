#!/usr/bin/env bash

#######################################################
# GENERAL CONFIGURATIONS
#######################################################

# History Configuration
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=erasedups:ignoredups:ignorespace
PROMPT_COMMAND='history -a'

# Auto-Adjust Terminal Size
shopt -s checkwinsize
shopt -s histappend

# Disable Terminal Bell
bind "set bell-style visible"

# Enable Enhanced Auto-Completion
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous On"

# Enable Colors for ls and grep
export CLICOLOR=1
alias grep='grep --color=always'

# Load Starship and Zoxide if Installed
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

#######################################################
# FASTFETCH CONFIGURATION
#######################################################

# Ensure Fastfetch runs with the custom configuration
if command -v fastfetch &> /dev/null; then
    fastfetch --config ~/mykali/config.jsonc
fi

#######################################################
# ALIASES
#######################################################

# Navigation Shortcuts
alias home='cd ~'
alias tools='cd ~/tools'
alias up='cd ..'
alias ..='cd ..'
alias ...='cd ../..'

# Networking Utilities
alias openports='netstat -tuln'

# Safety Aliases
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I --preserve-root'

# Utility Aliases
alias cls='clear'
alias myip='curl -s ifconfig.me'

# Quick Updates
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'

#######################################################
# PATH UPDATES
#######################################################

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin"

# Ensure Tools Directory is in PATH
if [ -d "$HOME/tools" ]; then
    export PATH="$HOME/tools:$PATH"
fi
