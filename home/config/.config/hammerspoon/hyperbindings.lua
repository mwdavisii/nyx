-- Define the modifier key
local super = "cmd"


hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("AClock")

-- spoon.SpoonInstall:andUse("ReloadConfiguration")
-- spoon.ReloadConfiguration:start()
-- I like the manual one below better because of the notification. 
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
      if file:sub(-4) == ".lua" then
          doReload = true
      end
  end
  if doReload then
      hs.reload()
  end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")


hs.hotkey.bind(super, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

hs.hotkey.bind(super, "G", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = f.x - 10
  win:setFrame(f)
end)

hs.hotkey.bind(super, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(super, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

--toggle max
hs.hotkey.bind(super, "G", function()
  local win = hs.window.focusedWindow()
  if win ~= nil then
      win:setFullScreen(not win:isFullScreen())
  end
end)

--- start quick open applications 
function open_app(name)
  return function()
    hs.application.launchOrFocus(name)
    if name == 'Finder' then
      hs.appfinder.appFromName(name):activate()
    end
  end
end

--- quick open applications
hs.hotkey.bind(super, "C", open_app("Visual Studio Code"))
hs.hotkey.bind(super, "B", open_app("Google Chrome"))
hs.hotkey.bind(super, "O", open_app("Microsoft Outlook"))
hs.hotkey.bind(super, "T", open_app("Microsoft Teams (work or school)"))
--- end quick open applications

return {
  init = module_init
}