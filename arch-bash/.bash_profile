#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$HOME/.local/bin:$PATH"

# Start gnome-keyring-daemon if present
if hash gnome-keyring-daemon 2>/dev/null; then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
  export SSH_AUTH_SOCK
fi

# If we are in a login shell, start sway
if [ -z "$WAYLAND_DISPLAY" -a $(tty) = "/dev/tty1" -a "$XDG_SESSION_TYPE" != "wayland" ]; then
  exec sway-session
elif [ "$DESKTOP_SESSION" = "sway" -o "$DESKTOP_SESSION" = "sway-run" ]; then
  source "$HOME/.config/sway/env"
fi
