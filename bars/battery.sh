#!/usr/bin/env bash

parse_battery_details() {
  local battery_device=${BATTERY_NUMBER:=0}
  local response=$(acpi -b | grep "Battery ${battery_device}")

  state=$(echo "${response}" | grep -wo 'Full\|Charging\|Discharging')
  power=$(echo "${response}" | grep -o '[0-9]\+%' | tr -d '%')
  remaining_time=$(echo "${response}" | grep -o '[01][0-9]:[0-9][0-9]')
}

print_battery() {
  local critical_level=30

  local charging_icon=''
  local full_icon=' '
  local three_quarter_icon=''
  local half_icon=''
  local empty_icon=''
  local fg_color='^c#a8a19f^'

  parse_battery_details
  case "${state}" in
    Full)
      current_icon=$full_icon
      icon_color='^c#5ab738^'
      ;;
    Charging)
      current_icon=$charging_icon
      icon_color='^c#ffd700^'
      ;;
    Discharging)
      if [[ "${power}" -le "${critical_level}" ]]; then
        current_icon=$empty_icon
        icon_color='^c#f22c40^'
      elif [[ "${power}" -le '50' ]]; then
        current_icon=$half_icon
        icon_color='^c#d78700^'
      elif [[ "${power}" -le '75' ]]; then
        current_icon=$three_quarter_icon
        icon_color=$fg_color
      else
        current_icon=$full_icon
        icon_color='^c#5ab738^'
      fi
      ;;
  esac

  [[ -n $remaining_time ]] && remaining_time="(${remaining_time})"

  battery="${icon_color}${current_icon}${fg_color}${power}% ${remaining_time}"
  echo "${battery}"
}

print_battery

exit 0
