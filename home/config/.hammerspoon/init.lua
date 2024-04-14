-- Define the modifier key
local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

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

--- execute a shell command
function executeShellCommand(command)
  return function()
      hs.execute(command, true)
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

-- Commands
hs.hotkey.bind(super, "q", nil, function() hs.eventtap.keyStroke({"cmd"}, "q") end)
-- copy / paste / select all / select none / undo
hs.hotkey.bind({"ctrl"}, "a", nil, function() hs.eventtap.keyStroke({"cmd"}, "a") end)
hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "x", nil, function() hs.eventtap.keyStroke({"cmd"}, "x") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "z", nil, function() hs.eventtap.keyStroke({"cmd"}, "z") end)
hs.hotkey.bind({"ctrl"}, "f", nil, function() hs.eventtap.keyStroke({"cmd"}, "f") end)
hs.hotkey.bind({"ctrl"}, "s", nil, function() hs.eventtap.keyStroke({"cmd"}, "s") end)


-- Apps
hs.hotkey.bind(super, "C", open_app("Visual Studio Code"))
hs.hotkey.bind(super, "B", open_app("Google Chrome"))
hs.hotkey.bind(super, "O", open_app("Microsoft Outlook"))
hs.hotkey.bind(super, "T", open_app("Microsoft Teams (work or school)"))
hs.hotkey.bind(super, "return", open_app("Alacritty"))
hs.hotkey.bind(super, "K", open_app("Kitty"))
hs.hotkey.bind(super, "F", open_app("Finder"))
hs.hotkey.bind(super, "space", open_app("launchpad"))

-- Window Management
hs.hotkey.bind(superShift, "Right", moveToRightHalf())
hs.hotkey.bind(superShift, "Left", moveToLeftHalf())

hs.hotkey.bind(super, "G", toggle_fullscreen())

hs.hotkey.bind(super, "pageup", executeShellCommand("yabai -m window --toggle float; yabai -m window --toggle border"))
hs.hotkey.bind(super, "pagedown", executeShellCommand("yabai -m window --toggle split"))
-- Workspace Management

-- navigate work spaces
hs.hotkey.bind(super, "left", nil, function() hs.eventtap.keyStroke({"ctrl"}, "right") end)
hs.hotkey.bind(super, "right", nil, function() hs.eventtap.keyStroke({"ctrl"}, "left") end)
hs.hotkey.bind(super, "1", executeShellCommand("yabai -m space --focus 1"))
hs.hotkey.bind(super, "2", executeShellCommand("yabai -m space --focus 2"))
hs.hotkey.bind(super, "3", executeShellCommand("yabai -m space --focus 3"))
hs.hotkey.bind(super, "4", executeShellCommand("yabai -m space --focus 4"))
hs.hotkey.bind(super, "5", executeShellCommand("yabai -m space --focus 5"))

-- move windows to workspaces
hs.hotkey.bind(superShift, "1", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 1"))
hs.hotkey.bind(superShift, "2", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 2"))
hs.hotkey.bind(superShift, "3", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 3"))
hs.hotkey.bind(superShift, "4", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 4"))
hs.hotkey.bind(superShift, "5", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 5"))

return {
  init = module_init
}