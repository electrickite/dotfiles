#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# If we are running sway, start gnome-keyring
if [ "$DESKTOP_SESSION" = "sway" ] || [ "$DESKTOP_SESSION" = "sway-run" ]; then
  eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
  export SSH_AUTH_SOCK
  export _JAVA_AWT_WM_NONREPARENTING=1
fi
