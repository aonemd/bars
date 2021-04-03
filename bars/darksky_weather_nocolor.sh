#!/usr/bin/env bash

main() {
  print_weather

  exit 0
}

print_weather() {
  local clear_day_icon=''
  local clear_night_icon=''
  local partly_cloudy_day_icon=''
  local partly_cloudy_night_icon=''
  local cloudy_icon=''
  local rain_icon=''
  local sleet_icon=''
  local snow_icon=''
  local wind_icon=''
  local fog_icon=''
  local celsius_icon='°C'

  parse_weather_details
  case "${forecast}" in
    clear-day)            current_icon=$clear_day_icon;;
    clear-night)          current_icon=$clear_night_icon;;
    partly-cloudy-day)    current_icon=$partly_cloudy_day_icon;;
    partly-cloudy-night)  current_icon=$partly_cloudy_night_icon;;
    cloudy)               current_icon=$cloudy_icon;;
    rain)                 current_icon=$rain_icon;;
    sleet)                current_icon=$sleet_icon;;
    snow)                 current_icon=$snow_icon;;
    wind)                 current_icon=$wind_icon;;
    fog)                  current_icon=$fog_icon;;
  esac

  weather="${current_icon} ${temperature}${celsius_icon}"
  echo "${weather}"
}

parse_weather_details() {
  local api_key=$WEATHER_API_KEY
  local city_id=$WEATHER_CITY_GEOLOCATION
  local api_parameters="exclude=minutely,hourly,daily,alerts,flags&units=si"
  local api_url="https://api.darksky.net/forecast/${api_key}/${city_id}?${api_parameters}"

  local response=$(curl -s "${api_url}")
  [[ -z $response ]] && exit 0

  forecast=$(echo "${response}" \
    | grep -o -e '\"icon\":\"[a-zA-Z-]*\"' \
    | awk -F ':' '{print $2}' \
    | tr -d '"')

  temperature=$(echo "${response}" \
    | grep -o -e '\"temperature\":\-\?[0-9]*' \
    | awk -F ':' '{print $2}' \
    | tr -d '"')
}

main "$@"
