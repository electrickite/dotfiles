#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias open=mimeo
alias pacupdate='sudo pacman -Syu && aurman -Su --aur --devel --needed'

source /usr/share/bash-completion/bash_completion
source /usr/share/chruby/chruby.sh
source /usr/share/chruby/auto.sh
source /usr/share/nvm/init-nvm.sh

if [ -f ~/.config/bash/common ]; then
  source ~/.config/bash/common
fi
