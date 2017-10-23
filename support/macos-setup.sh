#!/bin/bash

# Set up OS X

# Before running install the following:
# Xcode (App store, be sure to open once and accept license)
# XQuartz (http://www.xquartz.org)
# If available, copy keys.tar.gpg to your home directory

# Config
ruby_version="2.4"


echo "-- Mac setup script --"
echo "WARNING: This script should only be used to configure new machines!"
echo
read -p "Press [Enter] to start setup..."

cd $HOME

# Get user info
echo -n "Enter your name: "
read full_name
echo -n "Enter your email address: "
read email_address

# Ensure XCode developer tools are installed
echo "Installing XCode developer tools"
sudo xcode-select --install
read -p "Press [Enter] to continue AFTER installation has finished..."

if [[ ! -d "$HOME/.dotfiles" ]]; then
  echo "Could not find $HOME/.dotfiles. Aborting..."; exit 1
fi

rm -f ~/.bashrc ~/.bash_profile ~/.gitconfig ~/.vimrc

exclude_files=".DS_Store|.git|support"
GLOBIGNORE=".:.."

for path in $HOME/.dotfiles/*; do
  filename=$(basename "$path")
  if [[ ! $filename =~ ^($exclude_files)$ ]]; then
    ln -s "$path" "$HOME/$filename"
  fi
done

for path in $HOME/.dotfiles/os/mac/*; do
  filename=$(basename "$path")
  if [[ ! $filename =~ ^($exclude_files)$ ]]; then
    ln -s "$path" "$HOME/$filename"
  fi
done

echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

type -P brew &>/dev/null || { echo "brew command not found. Aborting..."; exit 1; }

brew update
brew tap caskroom/cask
brew tap caskroom/fonts
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php

echo "Installing a few useful tools..."
brew install ack
brew install autoconf
brew install chruby
brew install cmake
brew install composer
brew install ffmpeg
brew install gdbm
brew install gettext
brew install git
brew install gnupg2
brew install gnutls
brew install heroku-toolbelt
brew install httpie
brew install imagemagick
brew install libevent
brew install libffi
brew install libiconv
brew install libnet
brew install libpng
brew install libtasn1
brew install libtool
brew install libxml2
brew install libyaml
brew install lynx
brew install mariadb
brew install mcrypt
brew install n
brew install node
brew install nmap
brew install openssl
brew install pcre
brew install php-version
brew install php56
brew install phpunit
brew install pianobar
brew install postgresql
brew install readline
brew install ruby-install
brew install ssh-copy-id
brew install terminal-notifier
brew install tmux
brew install wget
brew install zlib

npm install -g bower
npm install -g gulp

echo "Installing applications..."
brew cask install burn
brew cask install disk-inventory-x
brew cask install dropbox
brew cask install firefox
brew cask install font-hack
brew cask install google-chrome
brew cask install hammerspoon
brew cask install hex-fiend
brew cask install iterm2
brew cask install keepassx
brew cask install mysqlworkbench
brew cask install paintbrush
brew cask install pgadmin3
brew cask install postman
brew cask install sublime-text
brew cask install skype
brew cask install transmission
brew cask install transmit

# Configure Sublime Text
echo "Starting Sublime Text"
subl
read -p "Press [Enter] to continue AFTER Sublime has started..."
rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
ln -s ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

echo "Installing updated Ruby..."
ruby-install ruby $ruby_version
source /usr/local/share/chruby/chruby.sh

chruby $ruby_version

gem install bundler
gem install rails

# Add SSH keys
cd "$HOME"

if [ -f keys.tar.gpg ]; then
    echo "keys.tar.gpg found. Extracting..."
    gpg -o - keys.tar.gpg | tar -xv
    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/id_rsa
    chmod 644 $HOME/.ssh/id_rsa.pub
    rm -i keys.tar.gpg
elif [ -d "$HOME/.ssh" ]; then
    echo "SSH key found."
else
    echo "No SSH keys file found. Generating new key..."
    ssh-keygen -t rsa -b 2048 -C $email_address
fi

echo "Performing additional configurations..."
git config --global user.name "$full_name"
git config --global user.email "$email_address"
git config --global include.path ~/.gitconfig_main

mkdir "$HOME/Sites"
mkdir "$HOME/projects"


echo "Setup complete!"
exit 0
