#!/usr/bin/env bash

workspace="$(hyprctl activeworkspace -j | jq -r '.id')"

hyprctl clients -j |
jq -r --argjson ws "$workspace" '
    .[]
    | select(.workspace.id == $ws)
    | select(.floating == true)
    | .address
' |
while read -r address; do
    [ -n "$address" ] || continue
    hyprctl dispatch settiled "address:$address" >/dev/null
done
