#!/usr/bin/env bash
# Launch one kmonad instance per connected keyboard. Every board has its own
# .kbd file because defsrc lists the keys that physically exist on it.
#
# Run from Hyprland's start hook (hypr/startup.lua); uses [[ ]] and functions,
# hence the explicit bash shebang rather than relying on /bin/sh.

osName=$(uname -s)
hostName=$(uname -n)

started=0
start() {
    echo "$1 found"
    kmonad "$HOME/.config/kmonad/linux/$2" &
    started=1
}

# Boards that can be plugged in next to another keyboard: start one instance
# each so both stay remapped. The Razer Huntsman Mini is a 60% (no F-row, no
# arrows), the Falchion is a 75%.
if [[ -e /dev/input/by-id/usb-Razer_Razer_Huntsman_Mini_00000000001A-event-kbd ]]; then
    start "Razer Huntsman Mini" razer-huntsman-mini-60.kbd
fi

if [[ -e /dev/input/by-id/usb-ASUSTeK_ROG_FALCHION_ACE_75_HE-event-kbd ]]; then
    start "ASUSTeK ROG FALCHION ACE 75 HE" rog-falchion-ace-75-he.kbd
fi

# Fallback set, only when none of the boards above is attached. The G915
# entries are alternates of one another (cable vs receiver, work vs home).
if [[ $started -eq 0 ]]; then
    if [[ -e /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd ]]; then
        start "Logitech G915 TKL (office)" g915-tkl-office.kbd
    elif [[ -e /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd ]]; then
        start "Logitech G915 TKL (home)" g915-tkl-home.kbd
    elif [[ -e /dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kbd ]]; then
        start "Logitech Receiver" g915-tkl-receiver-usb.kbd
    else
        start "Built In Keyboard" i8042.kbd
    fi
fi

# Stay alive as long as the instances do; hypr/default.nix killall's kmonad
# and re-runs this script when Hyprland starts.
if [[ $started -eq 1 ]]; then
    wait
fi
