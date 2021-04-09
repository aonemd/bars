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

  # if no artist or no title are found, quit
  if [ ! -z "$artist" -o ! -z "$title" ]; then
    media="${current_icon} ${artist} - ${title}"
    echo "${media}"
  fi
}

parse_media() {
  local response=$(playerctl metadata)
  artist=$(echo "$response" | grep -o ':artist\s*\(.*\)' | sed 's/:artist\s*//g' | cut -c 1-30)
  title=$(echo "$response" | grep -o ':title\s*\(.*\)' | sed 's/:title\s*//g' | cut -c 1-60)

  status=$(playerctl metadata --format '{{lc(status)}}')
}

main "$@"
