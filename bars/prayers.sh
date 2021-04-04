#!/usr/bin/env bash

main() {
  print_prayer

  exit 0
}

print_prayer() {
  parse_prayer_times
  [[ -z $seconds_left ]] && exit 0

  report_mode=${PRAYER_REPORT_MODE:=0}
  if [ $report_mode == 1 ]; then
    time_left=$(date -u -d "@${seconds_left}" +'%H:%M')
    prayer="${prayer_name} in ${time_left}"
  elif [ $report_mode == 2 ]; then
    minutes_left=$(($seconds_left / 60))
    prayer="${prayer_name} in ${minutes_left} Minutes"
  elif [ $report_mode == 3 ]; then
    hours_left=$(($seconds_left / 3600))
    prayer="${prayer_name} in ${hours_left} Hours"
  else
    prayer="${prayer_name} ${prayer_time}"
  fi

  echo "^c#5faf5f^ ${prayer}^c#a8a19f^"
}

parse_prayer_times() {
  local api_parameters=$PRAYER_API_PARAMS
  local api_url="http://api.aladhan.com/timingsByCity?${api_parameters}"

  local response=$(curl -s "${api_url}")
  [[ -z $response ]] && exit 0

  local prayers=('Fajr' 'Sunrise' 'Dhuhr' 'Asr' 'Maghrib' 'Isha')
  for prayer in "${prayers[@]}"; do
    local prayer_parsed_time=$(echo "${response}" \
      | grep -o -e "\"${prayer}\":\"[0-9][0-9]:[0-9][0-9]\"" \
      | awk -F "\"${prayer}\":" '{print $2}' \
      | tr -d '"')

    local prayer_time_in_seconds=$(date -d "${prayer_parsed_time}" +"%s")
    local seconds_until_prayer=$(($prayer_time_in_seconds - $(date +'%s')))
    if [ $seconds_until_prayer -gt 0 ]; then
      (( $seconds_until_prayer < min || min == 0 )) \
        && min=$seconds_until_prayer \
        && prayer_name=$prayer \
        && prayer_time=$prayer_parsed_time \
        && seconds_left=$min
    fi
  done
}

main "$@"
