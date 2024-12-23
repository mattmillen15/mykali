#!/usr/bin/env bash

#######################################################
# GENERAL CONFIGURATIONS
#######################################################

# History
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=erasedups:ignoredups:ignorespace
PROMPT_COMMAND='history -a'

# Auto-check terminal size
shopt -s checkwinsize
shopt -s histappend

# Disable terminal bell
bind "set bell-style visible"

# Enable auto-completion improvements
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous On"

# Colors for ls and grep
export CLICOLOR=1
alias grep='grep --color=always'

# Use Starship and Zoxide if available
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

#######################################################
# ALIASES
#######################################################

# Common navigation
alias home='cd ~'
alias tools='cd ~/tools'

# Networking
alias openports='netstat -tuln'

# Safety Measures
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I --preserve-root'

# Terminal Utilities
alias cls='clear'

#######################################################
# FUNCTIONS
#######################################################

# Extract archives
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case "$archive" in
                *.tar.bz2) tar xvjf "$archive" ;;
                *.tar.gz) tar xvzf "$archive" ;;
                *.zip) unzip "$archive" ;;
                *.7z) 7z x "$archive" ;;
                *) echo "Unknown archive: $archive" ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Show my external IP
alias myip="curl -s ifconfig.me"

#######################################################
# PATH UPDATES
#######################################################
export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin"
