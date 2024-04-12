-- Define the modifier key
local super = {"ctrl", "alt", "cmd", "shift"}

hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall:andUse("AClock")
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


-- Window Behavior Functions
function moveToLeftHalf()
    return function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
    
        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end

function moveToRightHalf()
    return function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end

function toggle_fullscreen()
    return function()
        local win = hs.window.focusedWindow()
        if win ~= nil then
            win:setFullScreen(not win:isFullScreen())
        end
    end
end

--- start quick open applications 
function open_app(name)
  return function()
    hs.application.launchOrFocus(name)
    if name == 'Finder' then
      hs.appfinder.appFromName(name):activate()
    end
  end
end

-- mimics shortcuts I setup in hyprland
-- modkey + q = quit
hs.hotkey.bind(super, "q", nil, function() hs.eventtap.keyStroke({"cmd"}, "q") end)
--toggle max
hs.hotkey.bind(super, "G", toggle_fullscreen())
hs.hotkey.bind(super, "Right", moveToRightHalf())
hs.hotkey.bind(super, "Left", moveToLeftHalf())
-- app shortcuts
hs.hotkey.bind(super, "C", open_app("Visual Studio Code"))
hs.hotkey.bind(super, "B", open_app("Google Chrome"))
hs.hotkey.bind(super, "O", open_app("Microsoft Outlook"))
hs.hotkey.bind(super, "T", open_app("Microsoft Teams (work or school)"))
hs.hotkey.bind(super, "return", open_app("Kitty"))

-- Attempt at mapping linux/windows functions 
-- copy / paste / select all / select none / undo
hs.hotkey.bind({"ctrl"}, "a", nil, function() hs.eventtap.keyStroke({"cmd"}, "a") end)
hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "z", nil, function() hs.eventtap.keyStroke({"cmd"}, "z") end)
hs.hotkey.bind({"ctrl"}, "f", nil, function() hs.eventtap.keyStroke({"cmd"}, "f") end)


return {
  init = module_init
}