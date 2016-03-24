#!/bin/bash
PATH=$PATH:/usr/local/bin

pbDir="${XDG_CONFIG_HOME:-$HOME/.config}/pianobar"
stationsFile="$pbDir/stations.ini"

notify () {
  if command -v terminal-notifier > /dev/null 2>&1; then
    terminal-notifier -title "$2" -subtitle "$3" -message "$1" -group 'pianobar'
  else
    osascript -e "display notification \"$1\" with title \"$2\" subtitle \"$3\""
  fi
}

# create variables
while read L; do
  k="`echo "$L" | cut -d '=' -f 1`"
  v="`echo "$L" | cut -d '=' -f 2`"
  export "$k=$v"
done < <(grep -e '^\(title\|artist\|album\|stationName\|songStationName\|pRet\|pRetStr\|wRet\|wRetStr\|songDuration\|songPlayed\|rating\|coverArt\|stationCount\|station[0-9]*\)=' /dev/stdin) # don't overwrite $1...

case "$1" in
  songstart)
    notify "$album" "$title" "$artist"
    ;;

  usergetstations)
    echo "[stations]" > "$stationsFile"
 
    for (( i=0; i<$stationCount; i++ ))
    do
      stationVar="station$i" 
      echo "s$i=${!stationVar}" >> "$stationsFile"
    done
    ;;

  *)
    if [ "$pRet" -ne 1 ]; then
      notify "$pRetStr" "Pianobar" "$1 failed"
    elif [ "$wRet" -ne 0 ]; then
      notify "$wRetStr" "Pianobar" "$1 failed"
    fi
    ;;
esac
