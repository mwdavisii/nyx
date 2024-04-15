local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

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
  hs.hotkey.bind(super, "G", toggle_fullscreen())