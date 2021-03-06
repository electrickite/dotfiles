export PATH="/usr/local/sbin:$PATH:$HOME/bin"

alias killvpn='sudo launchctl unload /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist'
alias startvpn='sudo launchctl load /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist'
alias start_postgres='postgres -D /usr/local/var/postgres'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; echo DNS flushed!'

fixmouse() {
  sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
  sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}

sethostname() {
  scutil --set ComputerName "$1"
  scutil --set LocalHostName "$1"
  scutil --set HostName "$1"
}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

export NVM_DIR="$HOME/.nvm"
source /usr/local/opt/nvm/nvm.sh

if [ -f ~/.config/bash/common ]; then
  source ~/.config/bash/common
fi

