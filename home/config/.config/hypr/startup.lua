-- One chained command: as separate exec_cmds these race, and kanshi can restart before
-- WAYLAND_DISPLAY lands in the systemd env ("failed to connect to display" -> start-limit-hit).
hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP; dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP; systemctl --user reset-failed kanshi; systemctl --user restart kanshi")
hl.exec_cmd("hyprctl keyword source ~/.cache/wal/colors-hyprland")

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --all")
  hl.exec_cmd([[gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark']])
  hl.exec_cmd("wl-clip-persist --clipboard regular")
  hl.exec_cmd("hyprpm reload -n")
  hl.exec_cmd("gamepad_idle_inhibit >/dev/null 2>&1")
  hl.exec_cmd("ambxst")
  hl.exec_cmd("~/.config/kmonad/selectKBD.sh")
end)
