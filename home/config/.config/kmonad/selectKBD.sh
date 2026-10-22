osName=$(uname -s)
hostName=$(uname -n)

#home915_usb="/dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd"
#home915_wless="/dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kbd"
#work915_usb="/dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd"
#work915_wless="/dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kbd"
#worklt_builtin="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

# try ASUS ROG Falchion Ace 75 HE
if [[ -e /dev/input/by-id/usb-ASUSTeK_ROG_FALCHION_ACE_75_HE-event-kbd ]]; then
    echo "ASUSTeK_ROG_FALCHION_ACE_75_HE found"
    kmonad ~/.config/kmonad/linux/rog-falchion-ace-75-he.kbd
elif [[ -e /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C-event-kbd ]]; then
    echo "Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_6AF4933C found"
    kmonad ~/.config/kmonad/linux/g915-tkl-office.kbd
elif [[ -e  /dev/input/by-id/usb-Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C-event-kbd ]]; then
    echo "Logitech_G915_TKL_LIGHTSPEED_Wireless_RGB_Mechanical_Gaming_Keyboard_3B30EB6C found"
    kmonad ~/.config/kmonad/linux/g915-tkl-home.kbd
elif [[ -e  /dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kbd ]]; then
    echo "Logitech Receiver Found"
    kmonad ~/.config/kmonad/linux/g915-tkl-receiver-usb.kbd
else
    echo "Built In Keyboard"
    kmonad ~/.config/kmonad/linux/i8042.kbd
fi
