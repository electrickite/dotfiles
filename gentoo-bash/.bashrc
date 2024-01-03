# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

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
  path="$(realpath "$1" 2>/dev/null)"
  if [[ $? -ne 0 || ! -e "$path" ]]; then
    path="$1"
  fi
  if [[ "$XDG_CURRENT_DESKTOP" == "sway" ]]; then
    swaymsg exec -- xdg-open \"$path\"
  elif [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
    gio open "$path"
  else
    xdg-open "$path"
  fi
}

alias ls='ls --color=auto'
alias lf=lfcd
alias mutt=mutt-run
alias ll='ls -lAh --group-dirs first'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias less='less -R'
alias ssh='TERM=xterm-256color ssh'

# Starship prompt
#eval "$(starship init bash)"

if [ -f ~/.config/bash/common ]; then
  source ~/.config/bash/common
fi
