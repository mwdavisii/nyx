-- Define the modifier key
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("AClock")
spoon.SpoonInstall:andUse("ReloadConfiguration")
sppon.SpoonInstall:andUse("PaperWM")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()


require("commands")
require("apps")
require("windows")

return {
    init = module_init
}


    