#!/bin/bash

# Set up Gentoo Linux

# Before running do the following:
#  - Install and configure sudo
#  - If available, copy the following into your home directory
#    * keys.tar.gpg
#    * cacert.crt

echo "-- Gentoo setup script --"
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
sudo emerge --noreplace \
  app-shells/bash-completion \
  net-dns/bind-tools \
  app-portage/cpuid2cpuflags \
  dev-util/ctags \
  net-misc/curl \
  sys-fs/e2fsprogs \
  sys-fs/exfat-utils \
  sys-apps/diffutils \
  sys-fs/dosfstools \
  sys-apps/ethtool \
  app-shells/fzf \
  app-portage/gentoolkit \
  dev-vcs/git \
  app-crypt/gnupg \
  sys-apps/lsb-release \
  sys-apps/less \
  www-client/lynx \
  sys-apps/man-db \
  sys-apps/man-pages \
  sys-apps/mlocate \
  sys-apps/net-tools \
  net-misc/networkmanager \
  sys-apps/nvme-cli \
  net-misc/openssh \
  sys-auth/polkit \
  sys-power/powertop \
  app-crypt/pinentry \
  dev-python/setuptools \
  net-misc/rsync \
  mail-client/s-nail \
  sys-apps/smartmontools \
  app-admin/stow \
  sys-fs/sysfsutils \
  media-fonts/terminus-font \
  sys-apps/texinfo \
  sys-apps/the_silver_searcher \
  app-misc/tmux \
  net-firewall/ufw \
  sys-apps/usbutils \
  app-arch/unzip \
  app-editors/vim \
  net-misc/wget \
  sys-apps/which \
  x11-misc/xdg-user-dirs \
  x11-misc/xdg-utils \
  sys-fs/xfsprogs \
  app-arch/zip

echo "Installing services..."
sudo cp -fv "$HOME/.dotfiles/os/gentoo/powertop.service" /etc/systemd/system/

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
stow -v $(cat os/gentoo/packages)
cd "$HOME"

echo "Generating ctags..."
ctags -f ~/.vim/systags $(equery files glibc | grep /usr/include/ | grep '.h')

# Add SSH keys
cd
if [ -f keys.tar.gpg ]; then
    echo "keys.tar.gpg found. Extracting..."
    gpg --pinentry-mode loopback keys.tar.gpg
    rm -rf ~/.gnupg
    tar -xf keys.tar
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/id_rsa"
    chmod 644 "$HOME/.ssh/id_rsa.pub"
    echo "pinentry-program /usr/bin/pinentry" > "$HOME/.gnupg/gpg-agent.conf"
    echo "max-cache-ttl 28800" >> "$HOME/.gnupg/gpg-agent.conf"
    echo "default-cache-ttl 28800" >> "$HOME/.gnupg/gpg-agent.conf"
    gpg-connect-agent reloadagent /bye
    rm -i keys.ta*
elif [ -d "$HOME/.ssh" ]; then
    echo "SSH key found."
else
    echo "No SSH keys file found. Generating new key..."
    ssh-keygen -t rsa -b 2048 -C "$email_address"
fi

if [ -n "$git_host" ]; then
  echo "Host $git_host" >> ~/.ssh/config
  echo "  Port 2222" >> ~/.ssh/config
fi

# Add private certificate to trust store
if [ -f "$HOME/cacert.crt" ]; then
    echo "Adding CA Certificate to trust store..."
    sudo cp "$HOME/cacert.crt" /usr/local/share/ca-certificates/localca.crt
    sudo update-ca-certificates
fi

echo "Performing additional configuration..."
git config --global user.name "$full_name"
git config --global user.email "$email_address"
git config --global include.path ~/.gitconfig_main

echo "Cleaning up..."
sudo updatedb

echo "Setup complete!"
exit 0
