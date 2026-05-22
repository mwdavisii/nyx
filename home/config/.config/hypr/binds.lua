local main_mod = "SUPER + CTRL + ALT"

hl.bind("CTRL + left", hl.dsp.layout("focus l"))
hl.bind("CTRL + right", hl.dsp.layout("focus r"))
hl.bind(main_mod .. " + left", hl.dsp.layout("move -col"))
hl.bind(main_mod .. " + right", hl.dsp.layout("move +col"))
hl.bind(main_mod .. " + SHIFT + left", hl.dsp.layout("move -col"))
hl.bind(main_mod .. " + SHIFT + right", hl.dsp.layout("move +col"))
hl.bind(main_mod .. " + comma", hl.dsp.layout("swapcol l"))
hl.bind(main_mod .. " + period", hl.dsp.layout("swapcol r"))
hl.bind(main_mod .. " + minus", hl.dsp.layout("colresize -conf"))
hl.bind(main_mod .. " + equal", hl.dsp.layout("colresize +conf"))
hl.bind(main_mod .. " + up", hl.dsp.layout("cycleheight +1"))
hl.bind(main_mod .. " + down", hl.dsp.layout("cycleheight -1"))

for i, key in ipairs({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }) do
  local workspace = (i == 10) and "10" or tostring(i)
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

local apps = {
  { key = "RETURN", cmd = "wezterm" },
  { key = "A", cmd = "alacritty" },
  { key = "K", cmd = "kitty" },
  { key = "B", cmd = "google-chrome-stable" },
  { key = "F", cmd = "thunar" },
  { key = "T", cmd = "google-chrome-stable --profile-directory=Default --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo" },
  { key = "O", cmd = "google-chrome-stable --profile-directory=Default --app-id=faolnafnngnfdaknnbpnkhgohbobgegn" },
  { key = "M", cmd = "google-chrome-stable --profile-directory=Default --app-id=hpfldicfbfomlpcikngkocigghgafkph" },
  { key = "C", cmd = "code" },
  { key = "N", cmd = "obsidian" },
  { key = "V", cmd = "cava_toggle" },
  { key = "D", cmd = "discord" },
  { key = "J", cmd = "flatpak run com.github.iwalton3.jellyfin-media-player" },
  { key = "Y", cmd = "wezterm start --class kitty-ytm -- ytm" },
}

for _, app in ipairs(apps) do
  hl.bind(main_mod .. " + " .. app.key, hl.dsp.exec_cmd(app.cmd))
end

hl.bind(main_mod .. " + SHIFT + B", hl.dsp.exec_cmd("firefox"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.exec_cmd("show_desktop"))
hl.bind(main_mod .. " + SHIFT + Y", hl.dsp.exec_cmd("pear-desktop"))

hl.bind(main_mod .. " + SPACE", hl.dsp.exec_cmd("ambxst run launcher"))
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd("ambxst run launcher"))
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd("ambxst lock"))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.exec_cmd("ambxst run powermenu"))
hl.bind(main_mod .. " + P", hl.dsp.exec_cmd("ambxst run dashboard"))

hl.bind(main_mod .. " + Q", hl.dsp.window.kill())
hl.bind(main_mod .. " + END", hl.dsp.exit())

hl.bind(main_mod .. " + G", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + home", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + page_down", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + page_up", hl.dsp.window.float({ action = "toggle" }))

hl.bind(main_mod .. " + S", hl.dsp.exec_cmd("~/.config/kanshi/switch.sh"))

hl.bind(
  main_mod .. " + SHIFT + up",
  hl.dsp.window.resize({ x = 0, y = -40, relative = true }),
  { repeating = true }
)
hl.bind(
  main_mod .. " + SHIFT + down",
  hl.dsp.window.resize({ x = 0, y = 40, relative = true }),
  { repeating = true }
)

hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[mkdir -p ~/Pictures && grim -g "$(slurp)" ~/Pictures/$(date +%Y%m%d_%H%M%S).png]]))

local media_binds = {
  { keys = "XF86AudioMicMute", cmd = "pamixer --default-source -t" },
  { keys = "XF86MonBrightnessDown", cmd = "brightnessctl set 20%-" },
  { keys = "XF86MonBrightnessUp", cmd = "brightnessctl set +20%" },
  { keys = "XF86AudioMute", cmd = "pamixer -t" },
  { keys = "XF86AudioLowerVolume", cmd = "pamixer -d 1" },
  { keys = "XF86AudioRaiseVolume", cmd = "pamixer -i 1" },
  { keys = "XF86AudioPlay", cmd = "playerctl play-pause" },
  { keys = "XF86AudioPause", cmd = "playerctl play-pause" },
  { keys = "XF86AudioNext", cmd = "playerctl next" },
  { keys = "XF86AudioPrev", cmd = "playerctl previous" },
}

for _, bind in ipairs(media_binds) do
  hl.bind(bind.keys, hl.dsp.exec_cmd(bind.cmd))
end

hl.bind(main_mod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind("SUPER + Tab", hl.dsp.window.bring_to_top())

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })
