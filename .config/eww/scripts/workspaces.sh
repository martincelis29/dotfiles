#!/usr/bin/env bash

get_workspaces() {
    spaces() {
        WORKSPACE_WINDOWS=$(hyprctl workspaces -j | jq 'map({key: .id | tostring, value: .windows}) | from_entries')
        seq 1 8 | jq --argjson windows "${WORKSPACE_WINDOWS}" --slurp -Mc 'map(tostring) | map({id: ., windows: ($windows[.]//0)})'
    }

    spaces
    socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        spaces
    done
}

get_current_workspace() {
    hyprctl monitors -j | jq --raw-output .[0].activeWorkspace.id
    socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | stdbuf -o0 grep '^workspace>>' | stdbuf -o0 awk -F '>>|,' '{print $2}'
}

change_current_workspace() {
    function clamp {
        min=$1
        max=$2
        val=$3
        python -c "print(max($min, min($val, $max)))"
    }

    direction=$1
    current=$2
    if test "$direction" = "down"; then
        target=$(clamp 1 10 $(($current + 1)))
        echo "jumping to $target"
        hyprctl dispatch workspace $target
    elif test "$direction" = "up"; then
        target=$(clamp 1 10 $(($current - 1)))
        echo "jumping to $target"
        hyprctl dispatch workspace $target
    fi
}

case "$1" in
getWorkspaces)
    get_workspaces
    ;;
getCurrentWorkspace)
    get_current_workspace
    ;;
changeCurrentWorkspace)
    change_current_workspace
    ;;
esac
