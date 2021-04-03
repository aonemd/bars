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

  media="${current_icon} ${artist} - ${title}"
  echo "${media}"
}

parse_media() {
  local response=$(playerctl metadata)
  artist=$(echo "$response" | grep -o ':artist\s*\(.*\)' | sed 's/:artist\s*//g')
  title=$(echo "$response" | grep -o ':title\s*\(.*\)' | sed 's/:title\s*//g')

  status=$(playerctl metadata --format '{{lc(status)}}')

}

main "$@"
