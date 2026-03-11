local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "shift"}

PaperWM = hs.loadSpoon("PaperWM")

-- Exclude apps from tiling (they float freely, matching Hyprland float rules)
PaperWM.window_filter = PaperWM.window_filter
    :setAppFilter("kitty", false)
    :setAppFilter("Alacritty", false)
    :setAppFilter("Steam", false)
    :setAppFilter("System Preferences", false)
    :setAppFilter("System Settings", false)
    :setAppFilter("Bitwarden", false)
    :setAppFilter("1Password", false)
    :setOverrideFilter({
        allowRoles = "AXStandardWindow",  -- reject dialogs, popups, sheets
    })

PaperWM:bindHotkeys({
    -- Focus movement (arrows, matches Hyprland mainMod + arrows)
    focus_left  = {super, "left"},
    focus_right = {super, "right"},
    focus_up    = {super, "up"},
    focus_down  = {super, "down"},


    -- Cycle focus (matches Hyprland ctrl + left/right workspace nav)
    focus_prev = {{"ctrl"}, "left"},
    focus_next = {{"ctrl"}, "right"},

    -- Swap/move windows (matches Hyprland move concepts)
    swap_left  = {superShift, "left"},
    swap_right = {superShift, "right"},
    swap_up    = {superShift, "up"},
    swap_down  = {superShift, "down"},

    -- Width cycling (matches Hyprland Shift+Up/Down column resize)
    cycle_width         = {super, "="},
    reverse_cycle_width = {super, "-"},

    -- Height cycling
    cycle_height         = {superShift, "="},
    reverse_cycle_height = {superShift, "-"},

    -- Fullscreen width (matches Hyprland mainMod + G)
    full_width = {super, "g"},

    -- Center window
    center_window = {super, "u"},

    -- Toggle floating (matches Hyprland mainMod + Page Up)
    toggle_floating = {super, "pageup"},

    -- Column management (slurp/barf)
    slurp_in = {super, "pagedown"},
    barf_out = {superShift, "pagedown"},

    -- Switch to a Mission Control space (matches Hyprland mainMod + 1-9)
    switch_space_1 = {super, "1"},
    switch_space_2 = {super, "2"},
    switch_space_3 = {super, "3"},
    switch_space_4 = {super, "4"},
    switch_space_5 = {super, "5"},
    switch_space_6 = {super, "6"},
    switch_space_7 = {super, "7"},
    switch_space_8 = {super, "8"},
    switch_space_9 = {super, "9"},

    -- Adjacent space navigation
    switch_space_l = {{"ctrl"}, "up"},
    switch_space_r = {{"ctrl"}, "down"},

    -- Move focused window to a space (matches Hyprland mainMod + Shift + 1-9)
    move_window_1 = {superShift, "1"},
    move_window_2 = {superShift, "2"},
    move_window_3 = {superShift, "3"},
    move_window_4 = {superShift, "4"},
    move_window_5 = {superShift, "5"},
    move_window_6 = {superShift, "6"},
    move_window_7 = {superShift, "7"},
    move_window_8 = {superShift, "8"},
    move_window_9 = {superShift, "9"},
})

PaperWM:start()