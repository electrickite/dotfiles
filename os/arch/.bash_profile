#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc


# If we are in a login shell, start sway
if [ -z "$DISPLAY" ] && \
   [ $(tty) = "/dev/tty1" ] && \
   [ "$XDG_SESSION_TYPE" != "wayland" ]
then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)

  export SSH_AUTH_SOCK
  export _JAVA_AWT_WM_NONREPARENTING=1
  export BEMENU_BACKEND=wayland
  export SDL_VIDEODRIVER=wayland
  export XDG_CURRENT_DESKTOP=sway

  # Read environment variables from environment.d
  eval $(sed -e '/^$/d' -e '/^\s*#/d' -e 's/^/export /' $HOME/.config/environment.d/*.conf)

  exec systemd-cat --identifier=sway sway
  exit 0
elif [ "$DESKTOP_SESSION" = "sway" ] || [ "$DESKTOP_SESSION" = "sway-run" ]; then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
  export SSH_AUTH_SOCK
  export _JAVA_AWT_WM_NONREPARENTING=1
  export BEMENU_BACKEND=wayland
  export SDL_VIDEODRIVER=wayland
  export XDG_CURRENT_DESKTOP=sway
fi
