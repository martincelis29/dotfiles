#!/usr/bin/env bash

PREV_TOTAL=0
PREV_IDLE=0
cpuFile="/tmp/.cpu_usage"

get_cpu() {
	if [[ -f "${cpuFile}" ]]; then
		fileCont=$(cat "${cpuFile}")
		PREV_TOTAL=$(echo "${fileCont}" | head -n 1)
		PREV_IDLE=$(echo "${fileCont}" | tail -n 1)
	fi

	CPU=($(cat /proc/stat | grep '^cpu '))
	unset CPU[0]
	IDLE=${CPU[4]}
	TOTAL=0

	for VALUE in "${CPU[@]:0:4}"; do
		let "TOTAL=$TOTAL+$VALUE"
	done

	if [[ "${PREV_TOTAL}" != "" ]] && [[ "${PREV_IDLE}" != "" ]]; then
		let "DIFF_IDLE=$IDLE-$PREV_IDLE"
		let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
		let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
		echo "${DIFF_USAGE}"
	else
		echo "?"
	fi

	echo "${TOTAL}" >"${cpuFile}"
	echo "${IDLE}" >>"${cpuFile}"
}

get_mem() {
	memTotal=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
	memFree=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

	memUsed=$((memTotal - memFree))
	memPercentage=$((memUsed * 100 / memTotal))
	echo "${memPercentage}"
}

get_updates() {
	updates_arch=$(checkupdates | wc -l) || updates_arch=0
	updates_aur=$(yay -Qua | wc -l) || updates_aur=0

	updates=$((updates_arch + updates_aur))

	if [[ $updates -eq 0 ]]; then
		echo "Updated!"
	else
		echo "$updates"
	fi
}

get_name() {
	fullname=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1 | tr -d "\n")

	if [ -z "$fullname" ]; then
		echo "$(whoami)@$(hostnamectl | awk 'FNR==1 {print $3}')"
	else
		echo "$fullname"
	fi
}

get_os() {
	os=$(lsb_release -is)

	if [ -n "$os" ]; then
		echo "$os"
	else
		echo "Unknown"
	fi
}

get_kernel() {
	echo "$(uname -r)"
}

get_pkgs() {
	echo "$(yay -Q | wc -l)"
}

get_wm() {
	echo "$XDG_CURRENT_DESKTOP"
}

tray() {
	if [[ "$(pidof waybar)" == "" ]]; then
		eww update tray=false
	else
		eww update tray=true
	fi

}

doc() {
	echo "Usage:
  system [Options]

Options:
	cpu		current CPU usage as a percentage
	memory		current Memory usage as a percentage
	updates		number of available updates for pacman and AUR packages
	name		full name associated with the current user
	os		operating system name
	kernel		current kernel version
	pkgs		total number of installed packages
	wm		current window manager or desktop environment"
}

case "$1" in
cpu)
	get_cpu
	;;
memory)
	get_mem
	;;
updates)
	get_updates
	;;
name)
	get_name
	;;
os)
	get_os
	;;
kernel)
	get_kernel
	;;
pkgs)
	get_pkgs
	;;
wm)
	get_wm
	;;
network-conf)
	nm-connection-editor
	;;
volume-toggle)
	pamixer -t
	;;
volume-conf)
	pavucontrol
	;;
tray)
	tray
	;;
*)
	doc
	;;
esac
