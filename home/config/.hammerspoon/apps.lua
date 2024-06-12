local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}


function executeShellCommand(command)
  return function()
      hs.execute(command, true)
  end
end

--- start quick open applications 
function open_app(name)
  return function()
    hs.application.enableSpotlightForNameSearches(true)
    app = hs.appfinder.appFromName(name)
    -- these functions are to open a new window for these apps.
    if app and name == 'Google Chrome' then
      hs.applescript([[
        tell application "/Applications/Google Chrome.app"
          make new window
          activate
        end tell
      ]])
      return
    end
    hs.application.launchOrFocus(name)
    if name == 'Finder' then
      app:activate()
    end
  end
end
  
-- Apps
hs.hotkey.bind(super, "C",            open_app("Visual Studio Code"))
hs.hotkey.bind(super, "B",            open_app("Google Chrome"))
hs.hotkey.bind(super, "O",            open_app("Microsoft Outlook"))
hs.hotkey.bind(super, "T",            open_app("Microsoft Teams"))
hs.hotkey.bind(super, "return",       open_app("iterm"))
hs.hotkey.bind(superShift, "return",  open_app("Alacritty"))
hs.hotkey.bind(super, "K",            open_app("Kitty"))
hs.hotkey.bind(super, "F",            open_app("Finder"))
hs.hotkey.bind(super, "space",        open_app("launchpad"))