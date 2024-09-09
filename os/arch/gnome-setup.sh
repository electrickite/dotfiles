#!/bin/bash
set -e

# Set up Arch Linux Gnome home directory

echo "-- Gnome home directory setup script --"
echo "WARNING: This script should only be used to configure new home directories!"
echo
read -p "Press [Enter] to start setup..."

cd "$HOME"

echo "Creating XDG directories..."
mkdir -pv ~/.config/systemd/user
mkdir -pv ~/.config/autostart
mkdir -pv ~/.local
mkdir -pv ~/.local/{state,bin,share}
xdg-user-dirs-update --force
mkdir -pv ~/Pictures/Screenshots
touch "~/Templates/Empty File"

echo "Configuring user services..."
ln -sfv /usr/bin/myterm "$HOME/.local/bin/xterm"
systemctl --user enable foot-server.socket gcr-ssh-agent.socket ydotool.service

echo "Installing extensions..."
mkdir -pv ~/.local/share/gnome-shell/extensions
git clone https://github.com/martinhjartmyr/gnome-shell-extension-focus-changer.git ~/.local/share/gnome-shell/extensions/focus-changer@heartmire

if [ -f "gnome-system-menu" ]; then
  cp -v gnome-system-menu ~/.local/bin/
  chmod 775 ~/.local/bin/gnome-system-menu
fi

echo "Configuring Gnome settings..."
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-size 32
gsettings set org.gnome.desktop.wm.preferences theme 'Adaitia-dark'
gsettings set org.gnome.desktop.default-applications.terminal exec 'footclient'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.Evince.Default inverted-colors true

gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super><Shift>q']"
gsettings set org.gnome.mutter.wayland.keybindings restore-shortcuts "['<Super><Shift>Escape']"
gsettings set org.gnome.mutter.keybindings switch-monitor "['<Super>o', 'XF86Display']"

gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "['<Control><Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Control><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Control><Super>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "['<Control><Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Shift><Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Shift><Super>Down']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Shift><Super>Left']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Shift><Super>Right']"
gsettings set org.gnome.desktop.wm.keybindings begin-move "['<Alt>F7', '<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Alt>F8', '<Super>r']"

nine="1 2 3 4 5 6 7 8 9"
for item in $nine
do
  gsettings set org.gnome.shell.keybindings switch-to-application-$item "[]"
done

for item in $nine
do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$item "['<Super>$item']"
done
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1', '<Super>Home']"

for item in $nine
do
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$item "['<Shift><Super>$item']"
done

echo "Setup complete!"
exit 0
