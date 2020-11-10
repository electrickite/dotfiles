#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/.config/bash/prompt

source /usr/share/bash-completion/bash_completion
source /usr/share/chruby/chruby.sh
source /usr/share/chruby/auto.sh
source /usr/share/nvm/init-nvm.sh

alias ls='ls --color=auto'
alias open=mimeo
alias pacupdate='sudo pacman -Syu && aurman -Su --aur --devel --needed'
alias todo=todo.sh
_completion_loader todo.sh
complete -F _todo todo

if [ -f ~/.config/bash/common ]; then
  source ~/.config/bash/common
fi
