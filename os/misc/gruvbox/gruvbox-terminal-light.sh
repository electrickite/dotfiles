#!/bin/sh

name="Gruvbox Light"

# Backgrond color
background="rgb(249,245,215)" # Hard (bg0_h)
#background="rgb(251,241,199)" # Medium (bg0)
#background="rgb(242,229,188)" # Soft (bg0_s)

# Foreground color
foreground="#504945" # fg2
#foreground="#3c3836" # fg1
#foreground="#282828" # fg0

# "Yellow" color
color03="#d79921";color11="#b57614" # Yellow
#color03="#d65d0e";color11="#af3a03" # Orange

# Palette colors
palette="['#fbf1c7','#cc241d','#98971a','${color03}','#458588','#b16286','#689d6a','#7c6f64','#928374','#9d0006','#79740e','${color11}','#076678','#8f3f71','#427b58','#3c3836']"


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
