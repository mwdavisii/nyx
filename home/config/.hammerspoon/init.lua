-- Define the modifier key
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("AClock")
spoon.SpoonInstall:andUse("ReloadConfiguration")
spoon.SpoonInstall.repos.PaperWM = {
    url = "https://github.com/mogenson/PaperWM.spoon",
    desc = "PaperWM.spoon repository",
    branch = "release",
}

spoon.SpoonInstall:andUse("PaperWM", {
    repo = "PaperWM",
    config = { screen_margin = 16, window_gap = 2 },
    start = true,
})
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()


require("commands")
require("apps")
require("windows")

return {
    init = module_init
}


