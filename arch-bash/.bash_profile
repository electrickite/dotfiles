#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$HOME/.local/bin:$PATH"
: ${BROWSER=lynx}
export BROWSER

# Start gnome-keyring-daemon if present
if hash gnome-keyring-daemon 2>/dev/null && [ "$DESKTOP_SESSION" != "gnome" ]; then
  eval $(gnome-keyring-daemon --start --components="pkcs11,secrets,ssh" --control-directory=/run/user/$(id -u)/keyring 2>/dev/null)
  export GNOME_KEYRING_CONTROL
  export SSH_AUTH_SOCK
fi

# If we are in a login shell, start sway
if [ -z "$WAYLAND_DISPLAY" -a $(tty) = "/dev/tty1" -a "$XDG_SESSION_TYPE" != "wayland" ]; then
  exec sway-start
elif [ "$DESKTOP_SESSION" = "sway" ]; then
  source "$HOME/.config/sway/env"
  eval $(sed -e '/^$/d' -e '/^\s*#/d' -e 's/^/export /' $HOME/.config/environment.d/*.conf)
  unset XCURSOR_THEME
  unset XCURSOR_SIZE
fi
