#!/bin/sh

name="Gruvbox Dark"

# Backgrond color
background="rgb(29,32,33)" # Hard (bg0_h)
#background="rgb(40,40,40)" # Medium (bg0)
#background="rgb(50,48,47)" # Soft (bg0_s)

# Foreground color
foreground="#d5c4a1" # fg2
#foreground="#ebdbb2" # fg1
#foreground="#fbf1c7" # fg0

# "Yellow" color
color03="#d79921";color11="#fabd2f" # Yellow
#color03="#d65d0e";color11="#fe8019" # Orange

# Palette colors
palette="['#282828','#cc241d','#98971a','${color03}','#458588','#b16286','#689d6a','#a89984','#928374','#fb4934','#b8bb26','${color11}','#83a598','#d3869b','#8ec07c','#ebdbb2']"


dlist_append() {
  local key="$1"; shift
  local val="$1"; shift

  local entries="$(
    {
      dconf read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
      echo "'$val'"
    } | head -c-1 | tr "\n" ,
  )"

  dconf write "$key" "[$entries]"
}

# Create default profile
dconfdir="/org/gnome/terminal/legacy/profiles:"
profile_id="$(uuidgen)"
profile_dir="$dconfdir/:$profile_id"

dlist_append $dconfdir/list "$profile_id"
dconf write $profile_dir/visible-name "'${name}'"

# set color palette
dconf write $profile_dir/palette "$palette"

# set foreground, background and highlight color
dconf write $profile_dir/bold-color "'${foreground}'"
dconf write $profile_dir/background-color "'${background}'"
dconf write $profile_dir/foreground-color "'${foreground}'"

# make sure the profile is set to not use theme colors
dconf write $profile_dir/use-theme-colors false

# set highlighted color to be different from foreground color
dconf write $profile_dir/bold-color-same-as-fg false
