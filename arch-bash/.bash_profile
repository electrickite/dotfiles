#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$HOME/.local/bin:$PATH"

# If we are in a login shell, start sway
if [ -z "$WAYLAND_DISPLAY" -a $(tty) = "/dev/tty1" -a "$XDG_SESSION_TYPE" != "wayland" ]; then
  exec sway-session
  exit 0
elif [ "$DESKTOP_SESSION" = "sway" -o "$DESKTOP_SESSION" = "sway-run" ]; then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
  export SSH_AUTH_SOCK
  source "$HOME/.config/sway/env"
fi
