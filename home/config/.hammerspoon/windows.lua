-- Window Management

-- Send message(s) to a running instance of yabai.

function toggle_fullscreen()
  return function()
      local win = hs.window.focusedWindow()
      if win ~= nil then
          win:setFullScreen(not win:isFullScreen())
      end
  end
end


local function yabai(commands)
  return function()
    for _, cmd in ipairs(commands) do
      os.execute("/opt/homebrew/bin/yabai -m " .. cmd)
    end
  end
end


function executeShellCommand(command)
  return function()
      hs.execute(command, true)
  end
end

-- Window Behavior Functions
local function moveToLeftHalf()
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
  
local function moveToRightHalf()
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

local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

hs.hotkey.bind(superShift, "right", moveToRightHalf())
hs.hotkey.bind(superShift, "left", moveToLeftHalf())
hs.hotkey.bind(super, "G", toggle_fullscreen())

hs.hotkey.bind(super, "pageup", yabai(" -m window --toggle float;  -m window --toggle border"))
hs.hotkey.bind(super, "pagedown", yabai(" -m window --toggle split"))
-- Workspace Management

-- navigate work spaces
hs.hotkey.bind(super, "1", yabai(" -m space --focus 1"))
hs.hotkey.bind(super, "2", yabai(" -m space --focus 2"))
hs.hotkey.bind(super, "3", yabai(" -m space --focus 3"))
hs.hotkey.bind(super, "4", yabai(" -m space --focus 4"))
hs.hotkey.bind(super, "5", yabai(" -m space --focus 5"))

-- move windows to workspaces
hs.hotkey.bind(superShift, "1", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 1"))
hs.hotkey.bind(superShift, "2", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 2"))
hs.hotkey.bind(superShift, "3", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 3"))
hs.hotkey.bind(superShift, "4", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 4"))
hs.hotkey.bind(superShift, "5", executeShellCommand("yabai -m window --space 1; yabai -m space --focus 5"))