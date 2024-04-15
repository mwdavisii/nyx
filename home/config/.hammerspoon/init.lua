-- Define the modifier key
local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

-- hs.loadSpoon("SpoonInstall")
-- #spoon.SpoonInstall.use_syncinstall = true
-- spoon.SpoonInstall:andUse("AClock")
-- spoon.SpoonInstall:andUse("ReloadConfiguration")
-- spoon.ReloadConfiguration:start()

require("aliases")
require("apps")
require("hswindow")

return {
    init = module_init
}