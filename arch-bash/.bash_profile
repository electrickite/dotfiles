#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

tty > $HOME/env.log
env >> $HOME/env.log

export PATH="$HOME/.local/bin:$PATH"
: ${BROWSER=lynx}
export BROWSER

# Start gnome-keyring-daemon if present
if hash gnome-keyring-daemon 2>/dev/null && [ "$XDG_SESSION_DESKTOP" != "gnome" ]; then
  eval $(gnome-keyring-daemon --start --components="pkcs11,secrets,ssh" --control-directory=/run/user/$(id -u)/keyring 2>/dev/null)
  export GNOME_KEYRING_CONTROL
  export SSH_AUTH_SOCK
fi

# If we are in a login shell, start sway
if [ -z "$WAYLAND_DISPLAY" -a $(tty) = "/dev/tty1" -a "$XDG_SESSION_TYPE" != "wayland" ]; then
  if command -v sway >/dev/null && command -v sway-start >/dev/null; then
    exec sway-start
  fi
fi
