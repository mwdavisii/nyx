local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

-- Send message(s) to a running instance of yabai.
local function yabai(commands)
  return function()
    for _, cmd in ipairs(commands) do
      os.execute("/opt/homebrew/bin/yabai -m " .. cmd)
    end
  end
end



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