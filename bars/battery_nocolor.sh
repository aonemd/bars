#!/usr/bin/env bash

main() {
  print_battery

  exit 0
}

print_battery() {
  local critical_level=10

  local charging_icon=''
  local full_icon=''
  local three_quarter_icon=''
  local half_icon=''
  local empty_icon=''

  parse_battery_details
  case "${state}" in
    Full)
      current_icon=$full_icon
      ;;
    Charging)
      current_icon=$charging_icon
      ;;
    Discharging)
      if [[ "${power}" -le "${critical_level}" ]]; then
        current_icon=$empty_icon
      elif [[ "${power}" -le '50' ]]; then
        current_icon=$half_icon
      elif [[ "${power}" -le '75' ]]; then
        current_icon=$three_quarter_icon
      else
        current_icon=$full_icon
      fi
      ;;
  esac

  [[ -n $remaining_time ]] && remaining_time="(${remaining_time})"

  battery="${current_icon} ${power}% ${remaining_time}"
  echo "${battery}"
}

parse_battery_details() {
  local battery_device=${BATTERY_NUMBER:=0}
  local response=$(acpi -b | grep "Battery ${battery_device}")

  state=$(echo "${response}" | grep -wo 'Full\|Charging\|Discharging')
  power=$(echo "${response}" | grep -o '[0-9]\+%' | tr -d '%')
  remaining_time=$(echo "${response}" | grep -o '[01][0-9]:[0-9][0-9]')
}

main "$@"
