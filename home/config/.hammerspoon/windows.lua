local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}
PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({
    -- increase/decrease width
    increase_width = {super, "="},
    decrease_width = {super, "-"},
    -- Focus movement (using arrows to avoid your h/l conflicts)
    focus_left  = {super, "left"},
    focus_right = {super, "right"},
    focus_up    = {super, "up"},
    focus_down  = {super, "down"},

    focus_prev = {ctrl, "left"},
    focus_next = {ctrl, "right"},

        -- switch to a new Mission Control space
    switch_space_1 = {super, "1"},
    switch_space_2 = {super, "2"},
    switch_space_3 = {super, "3"},
    switch_space_4 = {super, "4"},
    switch_space_5 = {super, "5"},
    switch_space_6 = {super, "6"},
    switch_space_7 = {super, "7"},
    switch_space_8 = {super, "8"},
    switch_space_9 = {super, "9"},

    -- move focused window to a new space and tile
    move_window_1 = {superShift, "1"},
    move_window_2 = {superShift, "2"},
    move_window_3 = {superShift, "3"},
    move_window_4 = {superShift, "4"},
    move_window_5 = {superShift, "5"},
    move_window_6 = {superShift, "6"},
    move_window_7 = {superShift, "7"},
    move_window_8 = {superShift, "8"},
    move_window_9 = {superShift, "9"}

})

PaperWM:start()