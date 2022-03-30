#!/bin/bash

# Set up Windows Subsystem for Linux (Debian)

# Before running do the following:
#  - Install and configure sudo
#  - If available, copy keys.tar.gpg and cacert.crt to your home directory

echo "-- WSL (Debian) setup script --"
echo "WARNING: This script should only be used to configure new installs!"
echo
read -p "Press [Enter] to start setup..."

cd $HOME

# Get user info
echo -n "Enter your name: "
read full_name
echo -n "Enter your email address: "
read email_address
echo -n "Enter your Windows username: "
read win_user
echo -n "Enter private git host: "
read git_host

if [[ ! -d "$HOME/.dotfiles" ]]; then
  echo "Could not find $HOME/.dotfiles. Aborting..."; exit 1
fi

# WSL may not currently umask properly
if [[ "$(umask)" = "0000" ]]; then
  umask 0002
fi

echo -n "Configure WSL mounts? [yN] "
read wsl
if [ "$wsl" = "y" -o "$wsl" = "Y" ]; then
  echo "Configuring WSL..."
  sudo mkdir -p /mnt/c
  sudo cp -n "$HOME/.dotfiles/os/wsl/wsl.conf" /etc

  echo "C:\  /mnt/c  drvfs  defaults,rw,noatime,uid=1000,gid=1000,umask=2,fmask=113,metadata,case=off  0  0" | sudo tee -a /etc/fstab >/dev/null
  echo "//localhost/C\$/Windows  /mnt/c/Windows  drvfs  defaults,ro,noatime,uid=1000,gid=1000,fmask=000,umask=000,case=off  0  0" | sudo tee -a /etc/fstab >/dev/null
  echo "//localhost/C\$/Program\040Files  /mnt/c/Program\040Files  drvfs  defaults,ro,noatime,uid=1000,gid=1000,fmask=000,umask=000,case=off  0  0" | sudo tee -a /etc/fstab >/dev/null
  echo "//localhost/C\$/Program\040Files\040(x86)  /mnt/c/Program\040Files\040(x86)  drvfs  defaults,ro,noatime,uid=1000,gid=1000,fmask=000,umask=000,case=off  0  0" | sudo tee -a /etc/fstab >/dev/null
  echo "//localhost/C\$/Users/${win_user}/AppData  /mnt/c/Users/${win_user}/AppData  drvfs  defaults,ro,noatime,uid=1000,gid=1000,fmask=000,umask=000,case=off  0  0" | sudo tee -a /etc/fstab >/dev/null
else
  sudo touch /etc/wsl.conf
  echo "options = metadata" | sudo tee -a /etc/wsl.conf >/dev/null
fi

echo "Updating packages..."
sudo apt-get update
sudo apt-get upgrade

echo "Installing new packages..."
sudo apt-get install \
  git \
  stow \
  man \
  bash-completion \
  openssh-client \
  silversearcher-ag \
  exuberant-ctags \
  gnupg2 \
  pass \
  pwgen \
  curl \
  wget \
  rsync \
  lynx \
  vim \
  tmux \
  net-tools \
  dnsutils \
  zip \
  unzip

echo "Creating XDG directories..."
mkdir -pv ~/.config
mkdir -pv ~/.local
mkdir -pv ~/.local/{state,bin}

echo "Initializing dotfile git submodules..."
cd "$HOME/.dotfiles"
git submodule update --init --recursive

echo "Linking config files..."
rm -f ~/.bashrc ~/.profile ~/.gitconfig
stow -v $(cat os/wsl/packages)
cd "$HOME"

# Install FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin --no-key-bindings --no-completion --no-update-rc

# Add SSH keys
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

echo "AddKeysToAgent  yes" >> ~/.ssh/config

if [ -n "$git_host" ]; then
  echo "Host $git_host" >> ~/.ssh/config
  echo "  Port 2222" >> ~/.ssh/config
fi

# Add private certificate to trust store
if [ -f "$HOME/cacert.crt" ]; then
  echo "Adding CA Certificate to trust store..."
  sudo cp "$HOME/cacert.crt" /usr/local/share/ca-certificates/
  sudo update-ca-certificates
fi

git config --global user.name "$full_name"
git config --global user.email "$email_address"
git config --global include.path ~/.gitconfig_main

sudo update-alternatives --config editor

mkdir -p "/mnt/c/Users/$win_user/projects"
ln -sf "/mnt/c/Users/$win_user/projects" ~/projects

echo "Setup complete!"
echo "Please reboot Windows or restart the LxssManager service"
exit 0
