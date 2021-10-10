#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source /usr/share/bash-completion/bash_completion

alias ls='ls --color=auto'
alias open=mimeo
alias pacupdate='sudo pacman -Syu && aurman -Syu --devel'
alias todo=todo.sh
alias gmni=amfora
_completion_loader todo.sh
complete -F _todo todo

# Starship prompt
eval "$(starship init bash)"

if [ -f ~/.config/bash/common ]; then
  source ~/.config/bash/common
fi
