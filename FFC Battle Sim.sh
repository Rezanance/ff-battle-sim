#!/bin/sh
printf '\033c\033]0;%s\a' FFC Battle Sim
base_path="$(dirname "$(realpath "$0")")"
"$base_path/FFC Battle Sim.x86_64" "$@"
