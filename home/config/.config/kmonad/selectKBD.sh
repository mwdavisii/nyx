osName=$(uname -s)
hostName=$(uname -n)

#home915_usb="/dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd"
#home915_wless="/dev/input/by-id/sb-Logitech_USB_Receiver-if01-event-kbd"
#work915_usb="/dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd"
#work915_wless="/dev/input/by-id/sb-Logitech_USB_Receiver-if01-event-kbd"
#worklt_builtin="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

# try work G915 TKL
if [[ -e /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd ]]; then
    echo "Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C found"
    kmonad ~/.config/kmonad/linux/g915-tkl-office.kbd
elif [[ -e  /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd ]]; then
    echo "Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C found"
    kmonad ~/.config/kmonad/linux/g915-tkl-home.kbd
elif [[ -e  /dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kb ]]; then
    echo "Logitech Receiver Found"
    kmonad ~/.config/kmonad/linux/g915-tkl-receiver-usb.kbd
else
    echo "Built In Keyboard"
    kmonad ~/.config/kmonad/linux/i8042.kbd
fi

[[ -e  /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd ]] && echo "exists"BC
[[ -e  /dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kb ]] && echo "exists"BC
