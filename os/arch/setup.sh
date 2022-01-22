#!/bin/bash

# Set up Arch Linux

# Before running do the following:
#  - Install and configure sudo
#  - If available, copy keys.tar.gpg and cacert.crt to your
#    home directory

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

echo -n "Install graphical environment? [yN] "
read graphical
if [ "$graphical" = "y" -o "$graphical" = "Y" ]; then
  sudo pacman -Syu --needed \
    antiword \
    bc \
    bemenu \
    blueman \
    bluez \
    bluez-utils \
    bolt \
    cairo \
    cdrtools \
    check \
    cmake \
    docx2txt \
    fd \
    fontconfig \
    freetype2 \
    gdk-pixbuf2 \
    gnome-keyring \
    gnome-themes-extra \
    go \
    grim \
    gsfonts \
    helvum \
    highlight \
    htop \
    imagemagick \
    jq \
    kanshi \
    libertinus-font \
    libnotify \
    libsecret \
    light \
    mako \
    meson \
    moreutils \
    neofetch \
    network-manager-applet \
    noto-fonts \
    odt2txt \
    otf-font-awesome \
    p7zip \
    pamixer \
    papirus-icon-theme \
    pass \
    pavucontrol \
    perl-image-exiftool \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    playerctl \
    polkit-gnome \
    qrencode \
    scdoc \
    slurp \
    starship \
    swappy \
    sway \
    swayidle \
    swaylock \
    trash-cli \
    ttf-croscore \
    ttf-dejavu \
    ttf-fira-mono \
    ttf-fira-sans \
    ttf-freefont \
    ttf-jetbrains-mono \
    ttf-roboto \
    udiskie \
    udisks2 \
    unrar \
    waybar \
    wireplumber \
    wl-clipboard \
    wtype \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-wlr \
    xorg-server-xwayland \
    xorg-xhost \
    xorg-xrdb

  aurman -Syu \
    adwaita-qt \
    archivemount \
    batsignal \
    cliphist \
    delay \
    dragon-drag-and-drop \
    edir \
    foot \
    glow-bin \
    j4-dmenu-desktop \
    libinput-gestures \
    libsixel \
    lf \
    menu-calc \
    mkinitcpio-colors-git \
    nerd-fonts-jetbrains-mono \
    networkmanager-dmenu-git \
    qgnomeplatform \
    setcolors-git \
    ttf-mac-fonts \
    ttf-roboto-slab \
    vim-gruvbox-git \
    wev \
    wob

  sudo pacman -D --asexplicit check cmake go meson scdoc

  sudo ln -sv bemenu /usr/bin/dmenu
  sudo ln -sv bemenu-run /usr/bin/dmenu-run

  sudo ln -sv /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
  sudo ln -sv /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
  ls -l /etc/fonts/conf.d/10-hinting-slight.conf
  sudo cp -pv "$HOME/.dotfiles/os/arch/xterm" /usr/local/bin/
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
  systemctl --user enable bash.service batsignal.service cliphist.service foot.service kanshi.service libinput-gestures.service mako.service nextcloud.service nm-applet.service polkit-gnome.service swayidle.service udiskie.service waybar.service wob.socket

  mkdir -pv ~/Pictures/screenshots
  mkdir -pv ~/projects
  ln -sv "$HOME/.dotfiles/os/arch/arch.jpg" "$HOME/Pictures/bg.jpg"
fi

echo -n "Install desktop applications? [yN] "
read desktop
if [ "$desktop" = "y" -o "$desktop" = "Y" ]; then
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
    pass-attr \
    perl-uri-find \
    urlview

  mkdir -pv ~/.mail/personal
  mkdir -pv ~/.local/state/mutt
  mkdir -pv ~/.local/state/msmtp
  mkdir -pv ~/.contacts
  mkdir -pv ~/.cache/vdirsyncer/status/

  sudo cp -v "$HOME/.dotfiles/os/arch/amfora.desktop" /usr/local/share/applications/

  echo "-- " >> ~/.config/mutt/sig
  echo "$full_name" >> ~/.config/mutt/sig
fi

echo -n "Install extra applications? [yN] "
read extra
if [ "$extra" = "y" -o "$extra" = "Y" ]; then
  sudo pacman -Syu --needed \
    calibre \
    edk2-ovmf \
    frotz-ncurses \
    gnome-clocks \
    gnome-chess \
    gnome-maps \
    gnome-mines \
    gnome-music \
    gnome-photos \
    gnome-sound-recorder \
    gnome-weather \
    gnuchess \
    networkmanager-openconnect \
    networkmanager-openvpn \
    openvpn \
    openconnect \
    qemu

  aurman -Syu \
    apachedirectorystudio \
    minecraft-launcher
fi

echo "Updating locate database..."
sudo updatedb

echo "Setup complete!"
exit 0
