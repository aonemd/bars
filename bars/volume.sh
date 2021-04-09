#!/usr/bin/env bash

SOUND_CARD="0"
# find an entry that has `headphone jack` in it using `amixer controls`
HEADPHONE_NUMID="18"

main() {
  print_volume

  exit 0
}

print_volume() {
  local speaker_up_icon="^c#5fafff^^c#a8a19f^"
  local speaker_mute_icon="^c#f22c40^ MUTE^c#a8a19f^"
  local headphone_up_icon="^c#5fafff^^c#a8a19f^"
  local headphone_mute_icon="^c#f22c40^ MUTE^c#a8a19f^"

  parse_volume
  case "${state}" in
    on)
      current_icon=$speaker_up_icon
      if [ "$headphone_state" == "on" ]; then
        current_icon=$headphone_up_icon
      fi

      volume="${current_icon} ${level}%"
      ;;
    off)
      current_icon=$speaker_mute_icon
      if [ "$headphone_state" == "on" ]; then
        current_icon=$headphone_mute_icon
      fi

      volume="${current_icon}"
      ;;
  esac
  echo "${volume}"
}

parse_volume() {
  local response=$(amixer get Master)
  level=$(echo "$response" | grep -o "\[[0-9]\+%\]" | sed "s/[^0-9]*//g")
  state=$(echo "$response" | grep -o "\[\(on\|off\)\]" | sed "s/[^(on|off)]//g")

  local headphone_response=$(amixer -c "$SOUND_CARD" cget numid="$HEADPHONE_NUMID")
  headphone_state=$(echo "$headphone_response" | grep -o "values=\(on\|off\)" | sed "s/[^(on|off)]//g")

}

main "$@"
