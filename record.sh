#!/bin/bash

set -eufo pipefail

cols=$(tput cols)
lines=$(tput lines)

if ! [[ "$cols" -eq 60 && "$lines" -eq 15 ]]; then
    echo "Need 60x15, not ${cols}x${lines}" >&2
    exit 1
fi

if ! [[ -f "$1" ]]; then
    echo "$1: file not found" >&2
    exit 1
fi

read -p "Ready? "
clear
echo -n "./show.py $1 -i" | pbcopy
asciinema rec -i 0.5
