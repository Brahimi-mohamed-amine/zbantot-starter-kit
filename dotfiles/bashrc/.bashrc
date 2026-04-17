# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias sbashrc='source ~/.bashrc'
alias ll='ls -lah --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
# PS1='[\u@\h \W]| '
# PS1='\[\e[1;34m\]\W\[\e[0m\] | ⚔️ '
PS1='\[\e[1;34m\]\W\[\e[0m\] \[\e[1;31m\]|\[\e[0m\] ⚔️ '

#pacman

alias u='doas pacman -Syu'
alias i='doas pacman -S'
alias q='doas pacman -Ss'
alias r='doas pacman -Rns'
alias vi='nvim'
alias cat='bat'
alias rm='trash-put'
#Free Disk Space
alias dfs='df -h'
#EDIT
alias bashrc='nvim ~/.bashrc'  
#Memory Usage
alias mem='free -h' 
alias n='nmtui'
alias setuplaravel='composer require --dev barryvdh/laravel-ide-helper'
#sound
#alias si='pamixer -i 1000'
#alias sd='pamixer -d 1000'
#vim MODE
set -o vi
#TRANSPARENCY
term="$(cat /proc/$PPID/comm)"
if [[ $term = "st" ]]; then
    transset-df "1.00" --id "$WINDOWID"  >>/dev/null
fi
#ctrl + d
set -o ignoreeof
export IGNOREEOF=100
#vulkan
#export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
#export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
#export PATH="/home/zbantot/.config/herd-lite/bin:$PATH"
#export PHP_INI_SCAN_DIR="/home/zbantot/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
#export PATH="$PATH:$HOME/flutter/bin"

# pnpm
#export PNPM_HOME="/home/zbantot/.local/share/pnpm"
#case ":$PATH:" in
#  *":$PNPM_HOME:"*) ;;
#  *) export PATH="$PNPM_HOME:$PATH" ;;
#esac
# pnpm end
