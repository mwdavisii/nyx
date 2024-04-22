-- Define the modifier key
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("AClock")
spoon.SpoonInstall:andUse("ReloadConfiguration")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()


require("commands")
require("apps")
require("hswindow")

return {
    init = module_init
}


