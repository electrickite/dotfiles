export PATH="/usr/local/sbin:$PATH:$HOME/bin"

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

chruby 2.3

alias killvpn='sudo launchctl unload /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist'
alias startvpn='sudo launchctl load /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist'
alias start_postgres='postgres -D /usr/local/var/postgres'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; echo DNS flushed!'

alias be='bundle exec'

fixmouse() {
  sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
  sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}

webroot() {
  ln -s "$1" "$HOME/Sites/webroot"
}

tunnel() {
  ssh -NL $1 $2
}

tunnels() {
  sudo -E ssh -F ~/.ssh/config -i ~/.ssh/id_rsa -NL $1 $2
}

docker-rmc() {
  docker ps -a | awk '{ print $1,$2 }' | grep "$1" | awk '{print $1 }' | xargs docker rm
}

sethostname() {
  scutil --set ComputerName "$1"
  scutil --set LocalHostName "$1"
  scutil --set HostName "$1"
}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if [ -f ~/.bashenv ]; then
  source ~/.bashenv
fi

