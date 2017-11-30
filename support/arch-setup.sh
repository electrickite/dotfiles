#!/bin/bash

# Set up Arch Linux

# Before running do the following:
#  - Install and configure sudo
#  - If available, copy keys.tar.gpg to your home directory

echo "-- Arch setup script --"
echo "WARNING: This script should only be used to configure new machines!"
echo
read -p "Press [Enter] to start setup..."

cd $HOME

# Get user info
echo -n "Enter your name: "
read full_name
echo -n "Enter your email address: "
read email_address

if [[ ! -d "$HOME/.dotfiles" ]]; then
  echo "Could not find $HOME/.dotfiles. Aborting..."; exit 1
fi

echo "Linking config files..."
rm -f ~/.bashrc ~/.bash_profile ~/.gitconfig
rm -rf ~/.config

exclude_files=".DS_Store|.git|support|os"
GLOBIGNORE=".:.."

for path in $HOME/.dotfiles/*; do
  filename=$(basename "$path")
  if [[ ! $filename =~ ^($exclude_files)$ ]]; then
    ln -s "$path" "$HOME/$filename"
  fi
done

for path in $HOME/.dotfiles/os/arch/*; do
  filename=$(basename "$path")
  if [[ ! $filename =~ ^($exclude_files)$ ]]; then
    ln -s "$path" "$HOME/$filename"
  fi
done

echo "Installing packages..."
sudo pacman -Syu --needed \
  git \
  openssh \
  pinentry \
  gnupg \
  curl \
  wget \
  rsync \
  lynx \
  vim \
  tmux \
  net-tools \
  dnsutils \
  exfat-utils \
  dosfstools \
  mlocate

if ! type -P pacaur &>/dev/null; then
  echo "Fetching current cower PGP key from PKGBUILD..."
  curl -s https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower | grep validpgpkeys
  read -p "Enter PGP to import [487EACC08557AD082088DABA1EB2638FF56C0C53] " cower_key
  cower_key=${cower_key:-487EACC08557AD082088DABA1EB2638FF56C0C53}
  gpg --receive-keys $cower_key

  echo "Installing pacaur..."
  mkdir aur-src
  cd aur-src
  git clone https://aur.archlinux.org/cower.git
  git clone https://aur.archlinux.org/pacaur.git
  cd cower
  makepkg -si
  cd ../pacaur
  makepkg -si
  cd ../..
  rm -rf aur-src
fi

# Add SSH keys
cd "$HOME"

if [ -f keys.tar.gpg ]; then
    echo "keys.tar.gpg found. Extracting..."
    gpg --pinentry-mode loopback keys.tar.gpg
    rm -rf ~/.gnupg
    tar -xf keys.tar
    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/id_rsa
    chmod 644 $HOME/.ssh/id_rsa.pub
    rm -i keys.ta*
elif [ -d "$HOME/.ssh" ]; then
    echo "SSH key found."
else
    echo "No SSH keys file found. Generating new key..."
    ssh-keygen -t rsa -b 2048 -C $email_address
fi

echo "Performing additional configuration..."
git config --global user.name "$full_name"
git config --global user.email "$email_address"
git config --global include.path ~/.gitconfig_main

mkdir "$HOME/projects"

sudo updatedb

echo "Setup complete!"
exit 0
