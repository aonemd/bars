#!/usr/bin/env bash

# requires `pacman-contrib`
#

LOWER_UPDATE_LIMIT=50
HIGHER_UPDATE_LIMIT=100

main() {
  update_counter=$(checkupdates | wc -l)
  [[ $update_counter -le $LOWER_UPDATE_LIMIT ]] && exit 0

  if [ $update_counter -ge $HIGHER_UPDATE_LIMIT ]; then
    echo " ^c#f22c40^$update_counter^c#a8a19f^"
  else
    echo " $update_counter"
  fi

  exit 0
}

main "$@"
