#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

source /usr/share/chruby/chruby.sh
source /usr/share/chruby/auto.sh

alias vi=vim
alias be='bundle exec'
