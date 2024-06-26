local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}
local yabai = require("yabai")

function toggle_fullscreen()
    return function()
        local win = hs.window.focusedWindow()
        if win ~= nil then
            win:setFullScreen(not win:isFullScreen())
        end
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
--  hs.hotkey.bind(super, "G", toggle_fullscreen())
hs.hotkey.bind(super, "g", function() yabai({"-m", "window", "--toggle", "zoom-fullscreen"}) end)  --["m"]

hs.hotkey.bind(superShift, "up", function() yabai({"-m", "window", "--toggle", "float"}) end)  --["/"]
hs.hotkey.bind(superShift, "down", function() yabai({"-m", "window", "--toggle", "split"}) end) 
-- doesn't apply to bsp
-- hs.hotkey.bind(super, "=", function() yabai({"-m", "window", "--ratio", "abs:0.38"}) end)  --["7"]
-- hs.hotkey.bind(super, "-", function() yabai({"-m", "window", "--ratio", "abs:0.5"}) end)  --["8"]
-- hs.hotkey.bind(super, "/", function() yabai({"-m", "window", "--ratio", "abs:0.62"}) end)  --["9"]
-- hs.hotkey.bind(super, "=", function() yabai({"-m", "space", "--balance"}) end)  --["-"]
