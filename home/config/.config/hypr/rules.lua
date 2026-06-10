hl.window_rule({ decorate = false })
hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(Alacritty)$" }, opacity = "0.8 0.8" })
hl.window_rule({ match = { float = true }, opacity = "0.8 0.8" })
hl.window_rule({
  match = { class = "^(Alacritty)$" },
  animation = "popin",
  float = true,
  opacity = "0.6 0.6",
  size = "55% 55%",
  center = true,
})
hl.window_rule({
  match = { class = "^(kitty)$" },
  animation = "popin",
  float = true,
  opacity = "0.6 0.6",
  size = "55% 55%",
  center = true,
})
hl.window_rule({ match = { class = "^(Alacritty)$" }, float = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(pinentry-)" }, stay_focused = true })
hl.window_rule({
  match = { class = "^(kitty-ytm)$" },
  animation = "popin",
  float = true,
  opacity = "0.6 0.6",
  size = "55% 55%",
  center = true,
})
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "always" })
hl.window_rule({ match = { class = "^(obs)$" }, idle_inhibit = "always" })
hl.window_rule({ match = { class = "^(mpv)$" }, idle_inhibit = "focus" })
hl.window_rule({ match = { class = "^(vlc)$" }, idle_inhibit = "focus" })
hl.window_rule({ match = { class = "^(chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default)$" }, idle_inhibit = "focus" })
hl.window_rule({ match = { class = "^(Jellyfin Media Player)$" }, idle_inhibit = "focus" })
