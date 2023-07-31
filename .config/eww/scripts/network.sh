#!/usr/bin/env bash

Check_Network() {
    ethernet_status=$(cat /sys/class/net/e*/operstate)
    if [[ $ethernet_status == "up" ]]; then
        echo "Ethernet"
    else
        wifi_status=$(nmcli -t -f DEVICE,STATE device show | awk -F: '$2=="connected"{print $1}')
        if [[ -n $wifi_status ]]; then
            echo "WiFi"
        else
            echo "Offline"
        fi
    fi
}

Check_Network

ip monitor link | while read -r line; do
    Check_Network
done
