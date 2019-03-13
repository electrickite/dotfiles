#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# If we are in a login shell, start sway
if [ -z "$DISPLAY" ] && \
   [ $(tty) = "/dev/tty1" ] && \
   [ "$XDG_SESSION_TYPE" != "wayland" ] && \
   [ -n "$(systemctl list-units --type=target --plain --no-pager --no-legend | grep multi-user.target)" ]
then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)

  export XDG_SESSION_TYPE=wayland \
         _JAVA_AWT_WM_NONREPARENTING=1 \
         SSH_AUTH_SOCK

  sway
  exit 0
elif [ "$DESKTOP_SESSION" = "sway" ] || [ "$DESKTOP_SESSION" = "sway-run" ]; then
  export _JAVA_AWT_WM_NONREPARENTING=1
fi
