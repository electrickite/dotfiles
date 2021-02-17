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

  export _JAVA_AWT_WM_NONREPARENTING=1
  export SSH_AUTH_SOCK
  export BEMENU_BACKEND=wayland
  export SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1

  # Read environment variables from environment.d
  set -a
  for file in ~/.config/environment.d/*
  do
    source "$file"
  done
  set +a

  exec sway
  exit 0
elif [ "$DESKTOP_SESSION" = "sway" ] || [ "$DESKTOP_SESSION" = "sway-run" ]; then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
  export SSH_AUTH_SOCK
  export _JAVA_AWT_WM_NONREPARENTING=1
  export BEMENU_BACKEND=wayland
  export SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1
fi
