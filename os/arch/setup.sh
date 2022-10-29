#!/bin/bash

# Set up Arch Linux

# Before running do the following:
#  - Install and configure sudo
#  - If available, copy the following into your home directory
#    * keys.tar.gpg
#    * cacert.crt

echo "-- Arch setup script --"
echo "WARNING: This script should only be used to configure new machines!"
echo
read -p "Press [Enter] to start setup..."

cd "$HOME"

# Get user info
echo -n "Enter your name: "
read full_name
echo -n "Enter your email address: "
read email_address
echo -n "Enter private git host: "
read git_host

if [[ ! -d "$HOME/.dotfiles" ]]; then
  echo "Could not find $HOME/.dotfiles. Aborting..."; exit 1
fi

echo "Installing packages..."
sudo pacman -Syu --needed \
  base-devel \
  bash-completion \
  ctags \
  curl \
  e2fsprogs \
  exfat-utils \
  diffutils \
  dnsutils \
  dosfstools \
  ethtool \
  fzf \
  git \
  gnupg \
  inetutils \
  lsb-release \
  less \
  lynx \
  man-db \
  man-pages \
  mlocate \
  net-tools \
  networkmanager \
  openssh \
  polkit \
  pinentry \
  python-setuptools \
  rsync \
  s-nail \
  smartmontools \
  stow \
  sysfsutils \
  terminus-font \
  texinfo \
  the_silver_searcher \
  tmux \
  ufw \
  usbutils \
  unzip \
  vim \
  wget \
  which \
  xdg-user-dirs \
  xdg-utils \
  zip

echo "Creating XDG directories..."
mkdir -pv ~/.config/systemd/user
mkdir -pv ~/.config/autostart
mkdir -pv ~/.local
mkdir -pv ~/.local/{state,bin,share}
xdg-user-dirs-update --force

echo "Initializing dotfile git submodules..."
cd "$HOME/.dotfiles"
git submodule update --init --recursive

echo "Linking config files..."
rm -f ~/.bashrc ~/.bash_profile ~/.gitconfig ~/.config/user-dirs.dirs ~/.config/user-dirs.locale
stow -v $(cat os/arch/packages)
cd "$HOME"

echo "Generating ctags..."
ctags -f ~/.vim/systags $(pacman -Qlq glibc | grep /usr/include/)

# Add SSH keys
cd
if [ -f keys.tar.gpg ]; then
    echo "keys.tar.gpg found. Extracting..."
    gpg --pinentry-mode loopback keys.tar.gpg
    rm -rf ~/.gnupg
    tar -xf keys.tar
    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/id_rsa
    chmod 644 $HOME/.ssh/id_rsa.pub
    echo "pinentry-program /usr/bin/pinentry" > $HOME/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 28800" >> $HOME/.gnupg/gpg-agent.conf
    echo "default-cache-ttl 28800" >> $HOME/.gnupg/gpg-agent.conf
    gpg-connect-agent reloadagent /bye
    rm -i keys.ta*
elif [ -d "$HOME/.ssh" ]; then
    echo "SSH key found."
else
    echo "No SSH keys file found. Generating new key..."
    ssh-keygen -t rsa -b 2048 -C $email_address
fi

if [ -n "$git_host" ]; then
  echo "Host $git_host" >> ~/.ssh/config
  echo "  Port 2222" >> ~/.ssh/config
fi

# Add private certificate to trust store
if [ -f "$HOME/cacert.crt" ]; then
    echo "Adding CA Certificate to trust store..."
    sudo trust anchor --store "$HOME/cacert.crt"
fi

# Install aurman
if ! type -P aurman &>/dev/null; then
  read -p "Enter aurman PGP key to import [465022E743D71E39] " aurman_key
  aurman_key=${aurman_key:-465022E743D71E39}
  gpg --receive-keys $aurman_key

  echo "Installing aurman..."
  cd ~
  git clone https://aur.archlinux.org/aurman.git aurman-build
  cd aurman-build
  makepkg -si
  cd ~
  rm -rf aurman-build
fi

echo "Performing additional configuration..."
git config --global user.name "$full_name"
git config --global user.email "$email_address"
git config --global include.path ~/.gitconfig_main

echo -n "Install graphical environment (Gnome, Sway, Both, No)? [gsbN] "
read graphical
graphical="$(echo "$graphical" | tr '[:lower:]' '[:upper:]')"
if [ "$graphical" != "G" -a "$graphical" != "S" -a "$graphical" != "B" ]; then
  graphical="N"
fi

if [ "$graphical" != "N" ]; then
  echo "Installing graphical packages..."
  sudo pacman -Syu --needed \
    adwaita-qt5 \
    adwaita-qt6 \
    antiword \
    bc \
    bitwarden \
    bitwarden-cli \
    bluez \
    bluez-utils \
    cairo \
    cdrtools \
    check \
    cmake \
    docx2txt \
    fd \
    fontconfig \
    foot \
    foot-terminfo \
    freetype2 \
    gdk-pixbuf2 \
    glow \
    gnome-keyring \
    gnome-themes-extra \
    go \
    gsfonts \
    helvum \
    highlight \
    htop \
    imagemagick \
    jq \
    lf \
    libertinus-font \
    libnotify \
    libsecret \
    libsixel \
    meson \
    moreutils \
    neofetch \
    noto-fonts \
    odt2txt \
    otf-font-awesome \
    p7zip \
    papirus-icon-theme \
    perl-image-exiftool \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    qgnomeplatform-qt5 \
    qgnomeplatform-qt6 \
    qrencode \
    scdoc \
    starship \
    swappy \
    trash-cli \
    ttf-croscore \
    ttf-dejavu \
    ttf-fira-mono \
    ttf-fira-sans \
    ttf-freefont \
    ttf-jetbrains-mono \
    ttf-roboto \
    unrar \
    wireplumber \
    wl-clipboard \
    xdg-desktop-portal-gtk \
    xorg-server-xwayland \
    xorg-xhost \
    xorg-xrdb

  aurman -Syu \
    archivemount \
    delay \
    dragon-drop \
    edir \
    libinput-gestures \
    mkinitcpio-colors-git \
    myterm \
    nerd-fonts-jetbrains-mono \
    setcolors-git \
    ttf-mac-fonts \
    ttf-roboto-slab \
    vim-gruvbox-git \
    wev

  sudo pacman -D --asexplicit check cmake go meson scdoc

  ln -sv /usr/bin/myterm "$HOME/.local/bin/xterm"

  sudo ln -sv /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
  sudo ln -sv /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
  ls -l /etc/fonts/conf.d/10-hinting-slight.conf
  sudo cp -v "$HOME/.dotfiles/os/arch/local-fonts.conf" /etc/fonts/local.conf
  sudo cp -fv "$HOME/.dotfiles/os/arch/freetype2.sh" /etc/profile.d/
  sudo cp -fv "$HOME/.dotfiles/os/arch/jre-fonts.sh" /etc/profile.d/
  sudo cp -fv "$HOME/.dotfiles/os/arch/vconsole.conf" /etc/
  sudo gdk-pixbuf-query-loaders --update-cache
  fc-cache -fv
  sudo fc-cache -fv

  sudo mkdir -p /usr/share/glib-2.0/schemas/
  sudo cp -fv "$HOME/.dotfiles/os/arch/10_local_defaults.gschema.override" /usr/share/glib-2.0/schemas/
  sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
  rm ~/.config/dconf/user

  systemctl --user daemon-reload
  systemctl --user enable bash@.service foot-server@.socket

  echo -n "Bitwarden server: "
  read bw_server
  echo -n "Bitwarden master password: "
  read bwpass
  echo "Setting bitwarden-menu PIN"
  gpg -co ~/.config/pass.gpg <(echo $bwpass); unset bwpass
  sed "s|EMAIL|${email_address}|g" ~/.config/bwm/config.ini.sample | sed "s|SERVER|${bw_server}|g" | sed "s|HOME|${HOME}|g" > ~/.config/bwm/config.ini

  mkdir -pv ~/Pictures/screenshots
  mkdir -pv ~/projects
  ln -sv "$HOME/.dotfiles/os/arch/arch.jpg" "$HOME/Pictures/bg.jpg"
fi

if [ "$graphical" = "G" -o "$graphical" = "B" ]; then
  echo "Installing GNOME..."
  sudo pacman -Syu --needed \
    dconf-editor \
    gdm \
    gnome \
    gnome-shell-extension-appindicator \
    gnome-tweak-tool \
    gpaste \
    rbw \
    xdg-desktop-portal-gnome \
    zenity

  aurman -Syu \
    gnome-pass-search-provider-git \
    gnome-shell-extension-caffeine

  rbw config set email "$email_address"
  rbw config set base_url "$bw_server"
  rbw config set lock_timeout 28800
  rbw config set pinentry pinentry-rbw
  mkdir -pv ~/.config/systemd/user/org.gnome.Pass.SearchProvider.service.d
  cp -v os/arch/gnome-pass-search-override.conf ~/.config/systemd/user/org.gnome.Pass.SearchProvider.service.d/override.conf

  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
  gsettings set org.gnome.desktop.interface cursor-size 32
  gsettings set org.gnome.desktop.wm.preferences theme 'Adaitia-dark'
  gsettings set org.gnome.desktop.default-applications.terminal exec 'footclient'
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
  gsettings set org.gnome.mutter experimental-features ['scale-monitor-framebuffer']

  gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super><Shift>q']"
  gsettings set org.gnome.mutter.wayland.keybindings restore-shortcuts "['<Super><Shift>Escape']"
  gsettings set org.gnome.mutter.keybindings switch-monitor ['<Super>d', 'XF86Display']

  nine="1 2 3 4 5 6 7 8 9"
  for item in $nine
  do
    gsettings set org.gnome.shell.keybindings switch-to-application-$item "[]"
  done

  for item in $nine
  do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$item "['<Super>$item']"
  done
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1', '<Super>Home]"

  for item in $nine
  do
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$item "['<Shift><Super>$item']"
  done

  sudo mkdir -p /etc/dconf/profile
  echo "user-db:user" | sudo tee /etc/dconf/profile/user
  echo "system-db:local" | sudo tee -a /etc/dconf/profile/user
  sudo mkdir -p /etc/dconf/db/local.d
  echo "[org/gnome/mutter]" | sudo tee /etc/dconf/db/local.d/00-hidpi
  echo "experimental-features=['scale-monitor-framebuffer']" | sudo tee -a /etc/dconf/db/local.d/00-hidpi
  sudo mkdir -p /etc/dconf/db/locks
  echo "/org/gnome/mutter/experimental-features" | sudo tee /etc/dconf/db/locks/hidpi
  sudo dconf update
fi

if [ "$graphical" = "S" -o "$graphical" = "B" ]; then
  echo "Installing Sway..."
  sudo pacman -Syu --needed \
    bemenu \
    blueman \
    bolt \
    grim \
    j4-dmenu-desktop \
    kanshi \
    light \
    mako \
    network-manager-applet \
    pamixer \
    pavucontrol \
    playerctl \
    polkit-gnome \
    slurp \
    sway \
    swaybg \
    swayidle \
    swaylock \
    udiskie \
    udisks2 \
    waybar \
    wtype \
    xdg-desktop-portal-wlr

  aurman -Syu \
    batsignal \
    cliphist-bin \
    menu-calc \
    networkmanager-dmenu-git \
    wob

  sudo ln -sv bemenu /usr/bin/dmenu
  sudo ln -sv bemenu-run /usr/bin/dmenu-run
  ln -s $(hostname)/swayidle ~/.config/sway/swayidle
  sudo cp -v "$HOME/.dotfiles/os/arch/sway-session" /usr/local/bin/
  sudo chmod 755 /usr/local/bin/sway-session
  sudo cp -v "$HOME/.dotfiles/os/arch/sway.desktop" /usr/local/share/wayland-sessions/
  sudo ln -sv sway /usr/bin/sway-start

  systemctl --user enable batsignal.service cliphist.service kanshi.service libinput-gestures.service mako.service nextcloud.service nm-applet.service polkit-gnome.service swayidle.service udiskie.service waybar.service wob.socket
fi

desktop="N"
if [ "$graphical" != "N" ]; then
  echo -n "Install desktop applications? [yN] "
  read desktop
fi
if [ "$desktop" = "Y" -o "$desktop" = "y" ]; then
  echo "Installing desktop applications..."
  sudo pacman -Syu --needed \
    amfora \
    aspell-en \
    baobab \
    cheese \
    dconf-editor \
    eog \
    evince \
    ext4magic \
    file-roller \
    firefox \
    gedit \
    gnome-calculator \
    gnome-characters \
    gnome-dictionary \
    gnome-disk-utility \
    gnome-font-viewer \
    gnome-logs \
    gnome-user-docs \
    goimapnotify \
    gvfs \
    gvfs-afc \
    gvfs-goa \
    gvfs-mtp \
    gvfs-nfs \
    gvfs-smb \
    hunspell \
    hunspell-en_US \
    isync \
    khard \
    libreoffice-fresh \
    linux-zen-docs \
    lsof \
    minicom \
    mpv \
    msmtp \
    msmtp-mta \
    mutt \
    nautilus \
    nautilus-sendto \
    nextcloud-client \
    nmap \
    notmuch \
    notmuch-mutt \
    ntfs-3g \
    openbsd-netcat \
    pandoc \
    perl \
    perl-curses-ui \
    perl-html-parser \
    perl-mime-tools \
    perl-term-readkey \
    pwgen \
    simple-scan \
    sushi \
    xdg-user-dirs-gtk \
    seahorse \
    transmission-gtk \
    tree \
    vdirsyncer \
    xchm

  aurman -Syu \
    extract_url \
    perl-uri-find \
    urlview

  mkdir -pv ~/.mail/personal
  mkdir -pv ~/.local/state/mutt
  mkdir -pv ~/.local/state/msmtp
  mkdir -pv ~/.contacts
  mkdir -pv ~/.cache/vdirsyncer/status/

  sudo mkdir -p /usr/local/share/applications
  sudo cp -v "$HOME/.dotfiles/os/arch/amfora.desktop" /usr/local/share/applications/

  echo "$full_name" >> ~/.config/mutt/sig
fi

extra="N"
if [ "$graphical" != "N" ]; then
  echo -n "Install extra applications? [yN] "
  read extra
fi
if [ "$extra" = "y" -o "$extra" = "Y" ]; then
  echo "Installing extra applications..."
  sudo pacman -Syu --needed \
    calibre \
    edk2-ovmf \
    frotz-ncurses \
    gnome-clocks \
    gnome-chess \
    gnome-maps \
    gnome-mines \
    gnome-music \
    gnome-nettool \
    gnome-photos \
    gnome-sound-recorder \
    gnome-weather \
    gnuchess \
    networkmanager-openconnect \
    networkmanager-openvpn \
    openvpn \
    openconnect \
    qemu-desktop

  aurman -Syu \
    apachedirectorystudio \
    minecraft-launcher
fi

echo "Cleaning up..."
sudo pacman -Sc
sudo updatedb

echo "Setup complete!"
exit 0
