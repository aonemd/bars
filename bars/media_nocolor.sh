#!/usr/bin/env bash

# requires `playerctl` installed
#

main() {
  print_media

  exit 0
}

print_media() {
  local play_icon=""
  local stop_icon=""

  parse_media

  current_icon=$play_icon

  if [ "$status" != 'playing' ]; then
    current_icon=$stop_icon
  fi

  if [ "$status" == 'No players found' ]; then
    exit 1
  fi

  if [ $player == "chrome" -o $player == "firefox" ]; then
    media_info="${title}"
  else
    media_info="${artist} - ${title}"
  fi

  echo "${current_icon} ${media_info}"
}

parse_media() {
  local response=$(playerctl metadata)
  artist=$(echo "$response" | grep -o ':artist\s*\(.*\)' | sed 's/:artist\s*//g' | cut -c 1-30)
  title=$(echo "$response" | grep -o ':title\s*\(.*\)' | sed 's/:title\s*//g' | cut -c 1-60)
  player=$(echo "$response" | grep -o '^\w\+' | head -1)

  status=$(playerctl metadata --format '{{lc(status)}}')
}

main "$@"
