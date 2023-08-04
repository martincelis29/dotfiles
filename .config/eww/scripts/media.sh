#!/usr/bin/env bash

player="--player=spotify"

function has_player() {
    if playerctl --player=spotify status &>/dev/null; then
        [[ $(playerctl --player=spotify status) = "Stopped" ]] && return 1 || return 0
    else
        return 1
    fi
}

########################## Title ##########################
function title() {
    echo " "
    [[ ! -z has_player && has_player ]] && playerctl "$player" metadata title
    playerctl "$player" metadata -f '{{ title }}' -F | while read -r title; do
        [[ ! -z has_player && has_player && ! -z "$title" ]] && playerctl "$player" metadata title || echo " "
    done
}

########################## Artist ##########################
function artist() {
    echo " "
    [[ ! -z has_player && has_player ]] && playerctl "$player" metadata artist
    playerctl "$player" metadata -f '{{ artist }}' -F | while read -r artist; do
        [[ ! -z has_player && has_player && ! -z "$artist" ]] && playerctl "$player" metadata artist || echo " "
    done
}

########################## Album ##########################
function album() {
    echo " "
    [[ ! -z has_player && has_player ]] && playerctl "$player" metadata album
    playerctl "$player" metadata -f '{{ album }}' -F | while read -r album; do
        [[ ! -z has_player && has_player && ! -z "$album" ]] && playerctl "$player" metadata album || echo " "
    done
}

########################## Cover ##########################
Cover=/tmp/cover.png
Background=/tmp/background.png
bkpCover=~/.config/eww/assets/background.svg

function cover() {
    albumart="$(playerctl "$player" metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')"
    [ $(playerctl "$player" metadata mpris:artUrl) ] && curl -s "$albumart" --output $Cover || cp $bkpCover $Cover
    echo "$Cover"
}

function background() {
    albumart="$(playerctl "$player" metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')"
    [ $(playerctl "$player" metadata mpris:artUrl) ] && curl -s "$albumart" --output "$Background" || cp "$bkpCover" "$Background"
    convert "$Background" -blur 0x8 "$Background"
    echo "$Background"
}

function follow_background() {
    echo "$bkpCover"
    [[ ! -z has_player && has_player ]] && cp "$bkpCover" "$Background" && echo "$Background"
    playerctl "$player" metadata -f '{{ mpris:artUrl }}' -F | while read -r backgroundPath; do
        if [[ ! -z has_player && has_player && ! -z "$backgroundPath" ]]; then
            if curl -s "$backgroundPath" --output "$Background"; then
                convert "$Background" -blur 0x8 "$Background"
                echo "$Background"
            else
                echo "$bkpCover"
            fi
        else
            echo "$bkpCover"
        fi
    done
}

# function follow_cover() {
#     echo $bkpCover
#     [[ ! -z has_player && has_player ]] && cp $bkpCover $Cover && echo $Cover
#     playerctl "$player" metadata -f '{{ mpris:artUrl }}' -F | while read -r coverPath; do
#         [[ ! -z has_player && has_player && ! -z "$coverPath" ]] && cover && echo $Cover || echo $bkpCover
#     done
# }

function follow_cover() {
    echo "$bkpCover"
    [[ ! -z has_player && has_player ]] && cp "$bkpCover" "$Cover" && echo "$Cover"
    playerctl "$player" metadata -f '{{ mpris:artUrl }}' -F | while read -r coverPath; do
        if [[ ! -z has_player && has_player && ! -z "$coverPath" ]]; then
            if curl -s "$coverPath" --output "$Cover"; then
                echo "$Cover"
            else
                echo "$bkpCover"
            fi
        else
            echo "$bkpCover"
        fi
    done
}

########################## Time ##########################
function ttime() {
    echo "--:-- / --:--"
    [[ ! -z has_player && has_player ]] && playerctl "$player" metadata -f "{{duration(position)}} / {{duration(mpris:length)}}"
    playerctl "$player" metadata -f '{{ duration(position) }} / {{ duration(mpris:length) }}' -F | while read -r ttime; do
        [[ ! -z has_player && has_player && ! -z "$ttime" ]] && echo "$ttime" || echo "--:-- / --:--"
    done
}

########################## Current Time ##########################
function current_time() {
    echo "--:--"
    [[ ! -z has_player && has_player ]] && playerctl "$player" metadata -f "{{duration(position)}}"
    playerctl "$player" metadata -f '{{ duration(position) }}' -F | while read -r ctime; do
        [[ ! -z has_player && has_player && ! -z "$ctime" ]] && echo "$ctime" || echo "--:--"
    done
}

function current_time_seconds() {
    playerctl "$player" metadata -f '{{ duration(position) }}' -F | while read -r time; do
        [ -z "$time" ] && time="0:00"
        minutes=${time%%:*}
        seconds=${time#*:}
        duration=$((10#$minutes * 60 + 10#$seconds))
        echo "$duration"
    done
}
<<Comment
function current_time_seconds() {
	time=$(playerctl "$player" position --format "{{ duration(position) }}")
	[ -z "$time" ] && time="0:00"
	IFS=":" read -r minutes seconds <<<"$time"
	duration=$((minutes * 60 + seconds))
	echo "$duration"
}
Comment

########################## Total Time ##########################
function total_time() {
    echo "--:--"
    [[ ! -z has_player && has_player ]] && playerctl "$player" metadata -f "{{duration(mpris:length)}}"
    playerctl "$player" metadata -f '{{ duration(mpris:length) }}' -F | while read -r ttime; do
        [[ ! -z has_player && has_player && ! -z "$ttime" ]] && echo "$ttime" || echo "--:--"
    done
}

function total_time_seconds() {
    playerctl "$player" metadata -f "{{ duration(mpris:length) }}" -F | while read -r length; do
        [ -z "$length" ] && length="0:00"
        seconds=$(echo "$length" | awk -F ':' '{ print ($1 * 60) + $2 }')
        echo "$seconds"
    done
}
<<Comment
function total_time_seconds() {
	length=$(playerctl "$player" metadata --format "{{ duration(mpris:length) }}")
	[ -z "$length" ] && length="0:00"
	seconds=$(echo "$length" | awk -F ':' '{ print ($1 * 60) + $2 }')
	echo "$seconds"
}
Comment

########################## Status ##########################
function class() {
    [[ ! -z has_player && has_player ]] && echo "Pause" || echo "Play"
    playerctl "$player" --follow status | while read -r status; do
        [[ ! -z has_player && has_player && "$status" = "Playing" ]] && echo "Pause" || echo "Play"
    done
}

########################## Status Icon ##########################
function icon() {
    [[ ! -z has_player && has_player && "$status" = "Playing" ]] && echo "" || echo ""
    playerctl "$player" --follow status | while read -r status; do
        [[ ! -z has_player && has_player && "$status" = "Playing" ]] && echo "" || echo ""
    done
}

########################## Volume ##########################
function volume() {
    local current_volume=$1
    local now_volume=$(bc -l <<<"$current_volume/100")
    playerctl "$player" volume "$now_volume"
}

function current_volume() {
    playerctl "$player" volume -F | while read -r volume; do
        formatted_volume=$(awk -v vol="$volume" 'BEGIN { printf "%.0f\n", vol * 100 }')
        echo "$formatted_volume"
    done
}

<<Comment
function current_volume() {
	volume=$(playerctl "$player" volume)
	formatted_volume=$(awk -v vol="$volume" 'BEGIN { printf "%.0f\n", vol * 100 }')
	echo $formatted_volume
}
Comment

########################## Shuffle ##########################
function shuffle() {
    if has_player; then
        playerctl "$player" shuffle toggle
    fi
}

function shuffle_color() {
    playerctl "$player" shuffle -F | while read -r shuffle_status; do
        color="#a0a0a0"
        [ "$shuffle_status" = "On" ] && color="#44c973"
        [ "$shuffle_status" = "Off" ] && color="#a0a0a0"
        echo "$color"
    done
}

########################## Loop ##########################
function loop() {
    loop=$(playerctl "$player" spotify loop)
    [[ $loop = "None" ]] && playerctl "$player" loop Playlist
    [[ $loop = "Playlist" ]] && playerctl "$player" loop Track
    [[ $loop = "Track" ]] && playerctl "$player" loop None
}

function loop_icon() {
    icon=""
    [ $(playerctl "$player" loop) = "None" ] && icon=""
    [ $(playerctl "$player" loop) = "Track" ] && icon=""
    [ $(playerctl "$player" loop) = "Playlist" ] && icon=""
    echo "$icon"
}

function loop_color() {
    color="#44c973"
    [ $(playerctl "$player" loop) = "None" ] && color="#a0a0a0"
    [ $(playerctl "$player" loop) = "Track" ] && color="#44c973"
    [ $(playerctl "$player" loop) = "Playlist" ] && color="#44c973"
    echo "$color"
}

########################## Media Functions ##########################
function toggle() {
    if has_player; then
        playerctl "$player" play-pause
    fi
}

function play() {
    if has_player; then
        playerctl play
    fi
}

function pause() {
    if has_player; then
        playerctl pause
    fi
}

function stop() {
    if has_player; then
        playerctl stop
    fi
}

function next() {
    if has_player; then
        playerctl "$player" next
    fi
}

function prev() {
    if has_player; then
        playerctl "$player" previous
    fi
}

if [[ $1 == "--volume" ]]; then
    current_volume=$2
    now_volume=$(python -c "print(float($current_volume)/100)")
    playerctl -p spotify volume "$now_volume"
fi

case "$1" in
"title") title ;;
"artist") artist ;;
"album") album ;;
"cover") cover ;;
"background") background ;;
"follow-background") follow_background ;;
"follow-cover") follow_cover ;;
"time") ttime ;;
"current-time") current_time ;;
"current-time-seconds") current_time_seconds ;;
"total-time") total_time ;;
"total-time-seconds") total_time_seconds ;;
"class") class ;;
"icon") icon ;;
"current-volume") current_volume ;;
"volume") volume "$2" ;;

"shuffle-color") shuffle_color ;;
"shuffle") shuffle ;;
"loop") loop ;;

"toggle") toggle ;;
"play") play ;;
"pause") pause ;;
"stop") stop ;;
"next") next ;;
"prev") prev ;;
esac
