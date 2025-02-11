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

# Enable Spellcheck for Directories
shopt -s cdspell

# Default Editor
export EDITOR=nvim
export VISUAL=nvim

# Enable colors for ls and grep
export CLICOLOR=1
alias grep='grep --color=always'

#######################################################
# FASTFETCH CONFIGURATION
#######################################################

# Run Fastfetch with custom configuration if installed
if command -v fastfetch &> /dev/null; then
    fastfetch --config ~/mykali/config.jsonc
fi

#######################################################
# ENHANCED DIRECTORY NAVIGATION
#######################################################

# Automatically list contents after cd
cd() {
    if [ -n "$1" ]; then
        builtin cd "$@" && ls -A --color=always
    else
        builtin cd ~ && ls -A --color=always
    fi
}

# Enable zoxide for smarter cd behavior
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
else
    echo -e "⚠️  Zoxide is not installed. Run 'sudo apt install zoxide'."
fi

# Enable typo correction and smart navigation
shopt -s cdspell
shopt -s dirspell
shopt -s autocd
PROMPT_COMMAND='history -a'

# Directory Stack Navigation
alias pd='pushd'
alias bd='popd'
alias dirs='dirs -v'

# Enable better history navigation
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#######################################################
# TRASH FUNCTIONALITY
#######################################################

# Safe rm alias to move files to trash instead of deleting
if command -v trash &> /dev/null; then
    alias rm='trash'
    alias emptytrash='trash-empty'
    alias listtrash='trash-list'
else
    echo -e "⚠️  trash-cli is not installed. Run 'sudo apt install trash-cli'."
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

# Quick Updates
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'

# Enhanced ls Commands
alias la='ls -Alh'                # Show hidden files
alias ll='ls -Fls'                # Long listing format
alias lt='ls -ltrh'               # Sort by date
alias ldir="ls -l | grep '^d'"    # List directories only

# Tmux alias to ensure it loads the config file properly
alias tmux="tmux -f ~/mykali/tmux/tmux.conf"

#######################################################
# FUNCTIONS
#######################################################

# Export VPN IP
export vpn_ip=$(ip -4 addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
export int_ip=$(hostname -I | awk '{print $1}')
export ext_ip=$(curl -s4 ifconfig.me)

# Whatsmyip function
whatsmyip() {
    # Output using exported variables
    echo -e "Internal IP: $int_ip"
    echo -e "External IP: $ext_ip"
    echo -e "VPN IP: $vpn_ip"
}

# Extract Archives
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case "$archive" in
                *.tar.bz2) tar xvjf "$archive" ;;
                *.tar.gz) tar xvzf "$archive" ;;
                *.bz2) bunzip2 "$archive" ;;
                *.rar) rar x "$archive" ;;
                *.gz) gunzip "$archive" ;;
                *.tar) tar xvf "$archive" ;;
                *.tbz2) tar xvjf "$archive" ;;
                *.tgz) tar xvzf "$archive" ;;
                *.zip) unzip "$archive" ;;
                *.7z) 7z x "$archive" ;;
                *) echo "❌ Unknown archive type: '$archive'" ;;
            esac
        else
            echo "❌ '$archive' is not a valid file!"
        fi
    done
}

# Copy with Progress Bar
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
    awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

#######################################################
# PATH CONFIGURATIONS
#######################################################

# Ensure Tools Directory is in PATH
if [ -d "$HOME/tools" ]; then
    export PATH="$HOME/tools:$PATH"
fi

# Add local binaries to PATH
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"

#######################################################
# SOURCE GLOBAL FILES
#######################################################

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#######################################################
# STARSHIP PROMPT & ZOXIDE INITIALIZATION
#######################################################

# Initialize Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
else
    echo -e "⚠️  Starship is not installed. Run 'sudo apt install starship'."
fi

# Tmux Starship Initialization
if [ -n "$TMUX" ]; then
    if command -v starship &> /dev/null; then
        eval "$(starship init bash)"
    fi
fi

# Initialize Zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
else
    echo -e "⚠️  Zoxide is not installed. Run 'sudo apt install zoxide'."
fi

#######################################################
# FINALIZATION
#######################################################

echo -e "✅ Environment Loaded. Happy Hacking!"
