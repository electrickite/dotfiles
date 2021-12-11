#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source /usr/share/bash-completion/bash_completion

LF_ICONS=""
lfcd() {
  if [ -z "$LF_ICONS" ]; then
    source "$HOME/.config/lf/icons"
  fi
  tmp="$(mktemp)"

  LFCD=1 LF_ICONS="$LF_ICONS" lf-launch -last-dir-path="$tmp" "$@"

  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    if [ -d "$dir" ]; then
      if [ "$dir" != "$(pwd)" ]; then
        cd "$dir"
      fi
    fi
  fi
}

open() {
  swaymsg exec -- xdg-open \"$(realpath "$1")\"
}

alias ls='ls --color=auto'
alias lf=lfcd
alias mutt=mutt-run
alias ll='ls -lAh --group-dirs first'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias less='less -R'
alias ssh='TERM=xterm-256color ssh'
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
