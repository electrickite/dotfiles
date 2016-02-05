export PATH="/usr/local/sbin:$PATH"

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

chruby 2.3

alias killvpn='sudo launchctl unload /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist'
alias startvpn='sudo launchctl load /Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist'
alias start_elasticsearch='elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml'
alias start_postgres='postgres -D /usr/local/var/postgres'

alias be='bundle exec'

fixmouse() {
  sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
  sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
}

webroot() {
  ln -s "$1" "$HOME/Sites/webroot"
}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if [ -f ~/.bashenv ]; then
  source ~/.bashenv
fi

