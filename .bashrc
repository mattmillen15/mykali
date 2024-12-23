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
# STARSHIP PROMPT
#######################################################

# Ensure Starship is properly initialized
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
else
    echo -e "⚠️  Starship is not installed. Run 'sudo apt install starship'."
fi

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
    echo -e "⚠️  zoxide is not installed. Run 'sudo apt install zoxide'."
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

alias home='cd ~'
alias tools='cd ~/tools'
alias up='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias myip='curl -s ifconfig.me'

#######################################################
# FUNCTIONS
#######################################################

# Show External and Internal IP
myip() {
    echo -n "Internal IP: "
    hostname -I | awk '{print $1}'
    echo -n "External IP: "
    curl -s ifconfig.me
    echo ""
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
# FINALIZATION
#######################################################

echo -e "✅ Environment Loaded. Happy Hacking!"
