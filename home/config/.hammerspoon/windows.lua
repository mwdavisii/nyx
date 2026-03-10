local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}
hs.loadSpoon("PaperWM")

-- Configure PaperWM
spoon.PaperWM.window_gap = 12
spoon.PaperWM.screen_margin = 16

-- Bind PaperWM using your existing 'super' and 'superShift' tables
spoon.PaperWM:bindHotkeys({
    -- Focus movement (using arrows to avoid your h/l conflicts)
    focus_left  = {super, "left"},
    focus_right = {super, "right"},
    focus_up    = {super, "up"},
    focus_down  = {super, "down"},

    -- Window placement
    swap_left   = {ctrl, "left"},
    swap_right  = {ctrl, "right"},
    swap_up     = {ctrl, "up"},
    swap_down   = {ctrl, "down"},

    -- Layout management
    center_window = {super, "c"},
    new_row       = {super, "n"},
    toggle_zoom   = {super, "f"},
    slurp_in      = {super, "i"},
    barf_out      = {super, "o"}
})

spoon.PaperWM:start()