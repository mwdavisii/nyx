osName=$(uname -s)
hostName=$(uname -n)

#home915_usb="/dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd"
#home915_wless="/dev/input/by-id/sb-Logitech_USB_Receiver-if01-event-kbd"
#work915_usb="/dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd"
#work915_wless="/dev/input/by-id/sb-Logitech_USB_Receiver-if01-event-kbd"
#worklt_builtin="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

if [[ $hostName == "olenos" ]]; then
    # try work G915 TKL
    if [[ -e /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd ]]; then
        echo "Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C found"
        kmonad ~/.config/kmonad/linux/g915-tkl-work.kbd
    elif [[ -e  /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd ]]; then
        # nope, now try home G915 TKL
        echo "Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C found"
        kmonad ~/.config/kmonad/linux/g915-tkl-home.kbd
    else
        #yep, it was home
        echo "Built In Keyboard"
        kmonad ~/.config/kmonad/linux/i8042.kbd
    fi
elif [[ $hostName == "hephaestus" ]]; then
    #launch logitech TKL
    kmonad ~/.config/kmonad/linux/g915-tkl-office.kbd
elif [[ $hostName == "athena" ]]; then
    echo "Need to setup athena"
    
else
    echo "Keyboard not configured"
fi


[[ -e  /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd ]] && echo "exists"