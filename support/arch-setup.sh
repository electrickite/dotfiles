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

echo "Initializing dotfile git submodules..."
cd "$HOME/.dotfiles"
git submodule update --init --recursive
cd $HOME

echo "Linking config files..."
rm -f ~/.bashrc ~/.bash_profile ~/.gitconfig
rm -rf ~/.config

exclude_files=".DS_Store|.git|.gitmodules|support|os"
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
  fzf \
  the_silver_searcher \
  ctags \
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

if ! type -P aurman &>/dev/null; then
  read -p "Enter aurman PGP key to import [465022E743D71E39] " aurman_key
  aurman_key=${aurman_key:-465022E743D71E39}
  gpg --receive-keys $aurman_key

  echo "Installing aurman..."
  git clone https://aur.archlinux.org/aurman.git aurman
  cd aurman
  makepkg -si
  cd ..
  rm -rf aurman
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
    echo "pinentry-program /usr/bin/pinentry" > $HOME/.gnupg/gpg-agent.conf
    gpg-connect-agent reloadagent /bye
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
