#!/usr/bin/env bash

language=$(setxkbmap -query | awk '/layout/{print $2}')
layout=${language::2}
layout=${layout^^}

echo "$layout"

exit 0
