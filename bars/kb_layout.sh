#!/usr/bin/env bash

main() {
  language=$(setxkbmap -query | awk '/layout/{print $2}')
  layout=${language::2}   # limit to 2 characters
  layout=${layout^^}      # UPCASE

  echo "^c#8787ff^ ^c#a8a19f^$layout"

  exit 0
}

main "$@"
