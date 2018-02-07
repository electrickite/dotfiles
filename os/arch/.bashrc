#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias open=mimeo
alias pacupdate='sudo pacman -Syu && pacaur -u --aur --devel --needed'

source /usr/share/chruby/chruby.sh
source /usr/share/chruby/auto.sh

if [ -f ~/.bash_common ]; then
  source ~/.bash_common
fi
