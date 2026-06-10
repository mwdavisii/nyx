hl.env("PATH", os.getenv("HOME") .. "/.nix-profile/bin:/nix/var/nix/profiles/default/bin:" .. os.getenv("PATH"))

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  input = {
    kb_layout = "us",
    kb_options = "grp:alt_shift_toggle",
    kb_rules = "",
    follow_mouse = 2,
    sensitivity = 1,
    touchpad = {
      natural_scroll = false,
    },
  },
  general = {
    layout = "scrolling",
  },
  decoration = {
    rounding = 10,
  },
  dwindle = {
    preserve_split = true,
  },
  scrolling = {
    column_width = 0.5,
    fullscreen_on_one_column = true,
  },
})

hl.curve("ease", { type = "bezier", points = { { 0.4, 0.02 }, { 0.21, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "ease", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "ease", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "ease" })
