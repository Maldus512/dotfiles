#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

BOLD="\[$(tput bold)\]"
RESET="\[$(tput sgr0)\]"
BLUE="\[$(tput setaf 4)\]"
CYAN="\[$(tput setaf 6)\]"
MAG="\[$(tput setaf 5)\]"
#PS1='[\u@\h \W]\$ '
export PROMPT_DIRTRIM=2
export PS1="${BOLD}[\u@$MALID ${BOLD}${BLUE}\w${RESET}${BOLD}]\$${RESET} "

set -o vi
. "$HOME/.cargo/env"

alias ls=exa
alias cat=batcat

[ -f "/home/maldus/.ghcup/env" ] && . "/home/maldus/.ghcup/env" # ghcup-env


export STM32_PRG_PATH=/home/maldus/Local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin